//
//  JsonParser.swift
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
    
    let typeKey = "type"
    let idKey = "id"
    let metaKey = "meta"
    let childrenKey = "children"
    
    /// The already registered factories
    private(set) var factories: [String: ComponentFactory] = [:]
    
    /// Registers a new ComponentFactory which will be used in `produce`
    ///
    /// - Parameter factory: the ComponentFactory to be registered
    public func register(_ factory: ComponentFactory) {
        factories[factory.typeName()] = factory
    }
    
    /// Produces a Component from a given JSONObject, which has two mandatory keys: `typeKey` and `idKey`
    ///
    /// - Parameter json: the JSONObject to be used
    /// - Returns: An optional Component
    /// - Throws: JSONFactoryError when a mandatory key is missing
    public func produce(from json: JSONObject) throws -> Component? {
        guard let type = json[typeKey] as? String else { throw JSONFactoryError.missing(json, typeKey) }
        guard let _ = json[idKey] as? String else { throw JSONFactoryError.missing(json, idKey) }
        
        let meta = json[metaKey] as? [String : Any]
        let children = json[childrenKey] as? [JSONObject] ?? []
        let componentChildren = try children.flatMap { try produce(from: $0) }
        
        return factories[type]?.produce(children: componentChildren, meta: meta)
    }
}
