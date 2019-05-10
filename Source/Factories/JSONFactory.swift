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

/// A factory that wraps `Component` builder closures (`SingleBuilder`, `WrapperBuilder`,
/// `ClusterBuilder` & `RuleBuilder`) and uses them to produce `Component`s
public final class JSONFactory {
    
    /// A closure to build a single `Component`
    public typealias SingleBuilder = (ComponentMeta?) -> Component
    
    /// A closure to build a wrapper `Component`
    public typealias WrapperBuilder = (Component, ComponentMeta?) -> Component
    
    /// A closure to build a cluster `Component`
    public typealias ClusterBuilder = ([Component], ComponentMeta?) -> Component
    
    /// A closure to build a rule `Component`
    public typealias RuleBuilder = Rule.RuleEvaluator
    
    fileprivate var singleBuilders: [String: SingleBuilder] = [:]
    fileprivate var wrapperBuilders: [String: WrapperBuilder] = [:]
    fileprivate var clusterBuilders: [String: ClusterBuilder] = [:]
    fileprivate var ruleBuilders: [String: RuleBuilder] = [:]
    
    /// Initialize a new JSONFactory
    public init() {
        // Empty but needed to be initialized from other modules
    }
    
    /// Registers a new `SingleBuilder` which will be used when producing the component
    ///
    /// - Parameters:
    ///   - type: a string identifying the component type
    ///   - builder: a `SingleBuilder` for the given type
    public func register(builder: @escaping SingleBuilder, forType type: String) {
        singleBuilders[type] = builder
    }
    
    /// Registers a new `WrapperBuilder` which will be used when producing the component
    ///
    /// - Parameters:
    ///   - type: a string identifying the component type
    ///   - builder: a `WrapperBuilder` for the given type
    public func register(builder: @escaping WrapperBuilder, forType type: String) {
        wrapperBuilders[type] = builder
    }
    
    /// Registers a new `ClusterBuilder` which will be used when producing the component
    ///
    /// - Parameters:
    ///   - type: a string identifying the component type
    ///   - builder: a `ClusterBuilder` for the given type
    public func register(builder: @escaping ClusterBuilder, forType type: String) {
        clusterBuilders[type] = builder
    }
    
    /// Registers a new `RuleBuilder` which will be used when producing the component
    ///
    /// - Parameters:
    ///   - type: a string identifying the component type
    ///   - builder: a `RuleBuilder` for the given type
    public func register(builder: @escaping RuleBuilder, forType type: String) {
        ruleBuilders[type] = builder
    }
    
    /// Produces a `Component` from a given `JSONObject`
    ///
    /// - Parameter json: the `JSONObject` to be used
    /// - Returns: An optional `Component`
    /// - Throws: `JSONFactoryError` when a mandatory key is missing. For more information on
    /// the mandatory keys, check the JSON schema documentation
    public func makeComponent(json: JSONObject) throws -> Component? {
        guard let structure = json[DocumentKey.structure] as? JSONObject else {
            throw JSONFactoryError.missing(json, DocumentKey.structure)
        }
        
        return try makeComponent(structure: structure)
    }
    
    private func makeComponent(structure json: JSONObject) throws -> Component? {
        guard let type = json[ComponentKey.type] as? String else {
            throw JSONFactoryError.missing(json, ComponentKey.type)
        }
        
        let meta = json[ComponentKey.meta] as? JSONObject
        let childObjects = json[ComponentKey.children] as? [JSONObject] ?? []
        let children = try childObjects.compactMap { try makeComponent(structure: $0) }
        let component = makeComponent(type: type, meta: meta, children: children)
        
        if let rule = JSONFactory.makeRule(object: json[ComponentKey.rule], builders: ruleBuilders),
            let component = component {
            return Component.rule(rule: rule, component: component)
        }
        
        return component
    }
}

extension JSONFactory {
    
    fileprivate func makeComponent(type: String, meta: JSONObject?, children: [Component]) -> Component? {
        var component: Component? = nil
        
        if let singleBuilder = singleBuilders[type] {
            component = singleBuilder(meta)
        } else if let wrapperBuilder = wrapperBuilders[type],
            let child = children.first {
            component = wrapperBuilder(child, meta)
        } else if let clusterBuilder = clusterBuilders[type] {
            component = clusterBuilder(children, meta)
        }
        
        return component
    }
    
    fileprivate static func makeRule(object: Any?, builders: [String: JSONFactory.RuleBuilder]) -> Rule? {
        if let rule = (object as? String)?.makeRule(builders: builders) {
            return rule
        }
        
        if let jsonObject = object as? JSONObject,
            let rule = jsonObject.makeRule(builders: builders) {
            return rule
        }
        
        return nil
    }
}

extension String {
    
    fileprivate func makeRule(builders: [String: JSONFactory.RuleBuilder]) -> Rule? {
        guard let ruleBuilder = builders[self] else {
            return nil
        }
        return Rule.simple(evaluator: ruleBuilder)
    }
}

extension Sequence where Iterator.Element == (key: String, value: Any) {
    
    fileprivate func makeRule(builders: [String: JSONFactory.RuleBuilder]) -> Rule? {
        guard let rule = first(where: { _ in true }) else {
            return nil
        }
        
        let values = rule.value as? [Any] ?? [rule.value]
        let rules = values.compactMap { JSONFactory.makeRule(object: $0, builders: builders) }
        
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
