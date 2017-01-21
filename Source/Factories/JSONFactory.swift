//
//  JSONFactory.swift
//  Matrioska
//
//  Created by Mathias Aichinger on 11/01/2017.
//  Copyright © 2017 runtastic. All rights reserved.
//

import Foundation

/// A JSONObject type
public typealias JSONObject = [String: Any]

/// An error type for JSONFactory
///
/// - missing: specifies that a mandatory key is missing
enum JSONFactoryError: Error {
    case missing(JSONObject, String)
}

fileprivate enum DocumentKey {
    static let structure = "structure"
}

fileprivate enum ComponentKey {
    static let type = "type"
    static let meta = "meta"
    static let children = "children"
    static let rule = "rule"
}

fileprivate enum RuleKey {
    static let and = "AND"
    static let or = "OR"
    static let not = "NOT"
}

/// A factory that wraps `Component` builder closures (ViewFactoryBuilder, `WrapperFactoryBuilder`,
/// `ClusterFactoryBuilder` & `RuleFactoryBuilder`) and uses them to produce `Component`s
public final class JSONFactory {
    
    /// A factory closure to build a view `Component`
    public typealias ViewFactoryBuilder = (ComponentMeta?) -> Component
    
    /// A factory closure to build a wrapper `Component`
    public typealias WrapperFactoryBuilder = (Component, ComponentMeta?) -> Component
    
    /// A factory closure to build a cluster `Component`
    public typealias ClusterFactoryBuilder = ([Component], ComponentMeta?) -> Component
    
    /// A factory closure to build a rule `Component`
    public typealias RuleFactoryBuilder = Rule.RuleEvaluator
    
    fileprivate var viewFactory: [String: ViewFactoryBuilder] = [:]
    fileprivate var wrapperFactory: [String: WrapperFactoryBuilder] = [:]
    fileprivate var clusterFactory: [String: ClusterFactoryBuilder] = [:]
    fileprivate var ruleFactory: [String: RuleFactoryBuilder] = [:]
    
    /// Initialize a new JSONFactory
    public init() {
        // Empty but needed to be initialized from other modules
    }
    
    /// Registers a new `ViewFactoryBuilder` which will be used when producing the component
    ///
    /// - Parameters:
    ///   - type: a string identifying this factory type
    ///   - factoryBuilder: a `ViewFactoryBuilder` to build a `Component`
    public func register(with type: String,
                         factoryBuilder: @escaping ViewFactoryBuilder) {
        viewFactory[type] = factoryBuilder
    }
    
    /// Registers a new `WrapperFactoryBuilder` which will be used when producing the component
    ///
    /// - Parameters:
    ///   - type: a string identifying this factory type
    ///   - factoryBuilder: a `WrapperFactoryBuilder` to build a `Component`
    public func register(with type: String,
                         factoryBuilder: @escaping WrapperFactoryBuilder) {
        wrapperFactory[type] = factoryBuilder
    }
    
    /// Registers a new `ClusterFactoryBuilder` which will be used when producing the component
    ///
    /// - Parameters:
    ///   - type: a string identifying this factory type
    ///   - factoryBuilder: a `ClusterFactoryBuilder` to build a `Component`
    public func register(with type: String,
                         factoryBuilder: @escaping ClusterFactoryBuilder) {
        clusterFactory[type] = factoryBuilder
    }
    
    /// Registers a new `RuleFactoryBuilder` which will be used when producing the component
    ///
    /// - Parameters:
    ///   - type: a string identifying this factory type
    ///   - factoryBuilder: a `RuleFactoryBuilder` to build a `Component`
    public func register(with type: String,
                         factoryBuilder: @escaping RuleFactoryBuilder) {
        ruleFactory[type] = factoryBuilder
    }
    
    /// Produces a `Component` from a given `JSONObject`
    ///
    /// - Parameter json: the `JSONObject` to be used
    /// - Returns: An optional `Component`
    /// - Throws: `JSONFactoryError` when a mandatory key is missing. For more information on
    /// the mandatory keys, check the JSON schema documentation 
    public func component(from json: JSONObject) throws -> Component? {
        guard let structure = json[DocumentKey.structure] as? JSONObject else {
            throw JSONFactoryError.missing(json, DocumentKey.structure)
        }
        
        return try component(fromStructure: structure)
    }
    
    private func component(fromStructure json: JSONObject) throws -> Component? {
        guard let type = json[ComponentKey.type] as? String else {
            throw JSONFactoryError.missing(json, ComponentKey.type)
        }
        
        let meta = json[ComponentKey.meta] as? JSONObject
        let children = json[ComponentKey.children] as? [JSONObject] ?? []
        let componentChildren = try children.flatMap { try component(fromStructure: $0) }
        let componentResult = component(from: type, meta: meta, children: componentChildren)
        
        if let rule = JSONFactory.rule(from: json[ComponentKey.rule] as Any, using: ruleFactory),
           let componentResult = componentResult {
            return Component.rule(rule: rule, component: componentResult)
        }
        
        return componentResult
    }
}

extension JSONFactory {
    
    fileprivate func component(from type: String, meta: JSONObject?, children: [Component]) -> Component? {
        var component: Component? = nil
        
        if let viewFactory = viewFactory[type] {
            component = viewFactory(meta)
        } else if let wrapperFactory = wrapperFactory[type],
            let componentChild = children.first {
            component = wrapperFactory(componentChild, meta)
        } else if let clusterFactory = clusterFactory[type] {
            component = clusterFactory(children, meta)
        }
        
        return component
    }
    
    fileprivate static func rule(from object: Any, using factory: [String: JSONFactory.RuleFactoryBuilder]) -> Rule? {
        if let rule = (object as? String)?.rule(using: factory) {
            return rule
        }
        
        if let jsonObject = object as? JSONObject,
            let rule = jsonObject.rule(using: factory) {
            return rule
        }
        
        return nil
    }
}

extension String {
    
    fileprivate func rule(using factory: [String: JSONFactory.RuleFactoryBuilder]) -> Rule? {
        guard let ruleFactory = factory[self] else {
                return nil
        }
        
        return Rule.simple(evaluator: ruleFactory)
    }
}

extension Sequence where Iterator.Element == (key: String, value: Any) {
    
    fileprivate func rule(using factory: [String: JSONFactory.RuleFactoryBuilder]) -> Rule? {
        guard let rule = first(where: { _ in true }) else {
            return nil
        }

        let values = rule.value as? [Any] ?? [rule.value]
        let rules = values.flatMap { JSONFactory.rule(from: $0, using: factory) }
        
        switch rule.key {
        case RuleKey.and where rules.count >= 2:
            return Rule.and(rules: rules)
        case RuleKey.or where rules.count >= 2:
            return Rule.or(rules: rules)
        case RuleKey.not where rules.count == 1:
            return Rule.not(rule: rules[0])
        default:
            return nil
        }
    }
}
