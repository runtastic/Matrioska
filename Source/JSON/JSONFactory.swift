//
//  JsonParser.swift
//  Matrioska
//
//  Created by Mathias Aichinger on 11/01/2017.
//  Copyright © 2017 runtastic. All rights reserved.
//

import Foundation

/// A factory that wraps ComponentFactory objects and uses them to produce Components
public class JSONFactory {
    
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
    
    /// Produces a Component from a given JSONObject
    ///
    /// - Parameter json: the JSONObject to be used
    /// - Returns: An optional Component
    /// - Throws an assertion if the given JSONObject does not have typeKey or idKey keys
    public func produce(from json: JSONObject) -> Component? {
        guard let type = json[typeKey] as? String,
              let _ = json[idKey] as? String else { fatalError("Missing mandatory fields") }
        
        let meta = json[metaKey] as? [String : Any]
        let children = json[childrenKey] as? [JSONObject] ?? []
        let componentChildren = children.flatMap { produce(from: $0) }
        
        return factories[type]?.produce(children: componentChildren, meta: meta)
    }
}
