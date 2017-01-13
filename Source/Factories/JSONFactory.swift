//
//  JSONFactory.swift
//  Matrioska
//
//  Created by Mathias Aichinger on 11/01/2017.
//  Copyright © 2017 runtastic. All rights reserved.
//

import Foundation

/// An error type for JSONFactory
///
/// - missing: specifies that a mandatory key is missing
enum JSONFactoryError: Error {
    case missing(JSONObject, String)
}

/// A factory that wraps ComponentFactory objects and uses them to produce Components
public final class JSONFactory {
    
    static let typeKey = "type"
    static let metaKey = "meta"
    static let childrenKey = "children"
    
    /// A factory closure to build a view `Component`
    public typealias ViewFactoryBuilder = (ComponentMeta?) -> Component
    
    /// A factory closure to build a wrapper `Component`
    public typealias WrapperFactoryBuilder = (Component, ComponentMeta?) -> Component
    
    /// A factory closure to build a cluster `Component`
    public typealias ClusterFactoryBuilder = ([Component], ComponentMeta?) -> Component
    
    private var viewFactory: [String: ViewFactoryBuilder] = [:]
    private var wrapperFactory: [String: WrapperFactoryBuilder] = [:]
    private var clusterFactory: [String: ClusterFactoryBuilder] = [:]
    
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
    
    /// Produces a `Component` from a given `JSONObject`, which has one mandatory key: `typeKey`
    ///
    /// - Parameter json: the `JSONObject` to be used
    /// - Returns: An optional `Component`
    /// - Throws: `JSONFactoryError` when a mandatory key is missing
    public func component(from json: JSONObject) throws -> Component? {
        guard let type = json[JSONFactory.typeKey] as? String else {
            throw JSONFactoryError.missing(json, JSONFactory.typeKey)
        }
        
        let meta = json[JSONFactory.metaKey] as? [String : Any]
        let children = json[JSONFactory.childrenKey] as? [JSONObject] ?? []
        let componentChildren = try children.flatMap { try component(from: $0) }
        var componentResult: Component?
        
        if let viewFactory = viewFactory[type] {
            componentResult = viewFactory(meta)
        } else if let wrapperFactory = wrapperFactory[type],
                  let componentChild = componentChildren.first {
            componentResult = wrapperFactory(componentChild, meta)
        } else if let clusterFactory = clusterFactory[type] {
            componentResult = clusterFactory(componentChildren, meta)
        }
        
        return componentResult
    }
}
