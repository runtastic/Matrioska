//
//  ComponentMeta.swift
//  Matrioska
//
//  Created by Alex Manzella on 16/11/16.
//  Copyright © 2016 runtastic. All rights reserved.
//

import Foundation

/// A protocol to create meta object that provides metadata for a Component
public protocol ComponentMeta {
    
    /// `ComponentMeta` should implement a subscript function
    /// to allow to retreive meta using a keyed subscript.
    /// A default implementation is provided and use reflection
    /// to retreive the values of the object's properties.
    ///
    /// - Parameter key: The key of the meta to retreive
    subscript(key: String) -> Any? { get }
}

/// A protocol used to clear Optionals when their static type is `Any`
/// to avoid Optional<Optional<T>>
fileprivate protocol OptionalProtocol {
    var wrappedValue: Any? { get }
}

extension Optional: OptionalProtocol {
    fileprivate var wrappedValue: Any? {
        return self
    }
}

extension ComponentMeta {

    /// The default implementation of the subscript uses reflection to mirror the object
    /// if the key represent a property, its value will be returned
    ///
    /// - Parameter key: the key of the value to retreive, must be the name of a property.
    public subscript(key: String) -> Any? {
        let mirror = Mirror(reflecting: self)
        if let value = mirror.children.first(where: { $0.label == key })?.value {
            // if the value is Optional (static type is Any)
            // we have to let the compiler know and return an Optional<Any>
            // otherwise since the return value is `Any?` we will get a `Optional<Optional<T>>`
            if let optional = value as? OptionalProtocol {
                return optional.wrappedValue
            }
            return value
        }
        
        return nil
    }
}

/// A type that can be expressed by a `ComponentMeta` type.
/// Adopting this protocol, `Component`s are able to materialize a `ComponentMeta` object
/// into this type using `ExpressibleByComponentMeta.materialize(_ )`.
public protocol ExpressibleByComponentMeta: ComponentMeta {
    
    /// An initializer that takes a `ComponentMeta` to retreive the necessary metadata
    /// in order to build this object.
    /// `ExpressibleByComponentMeta.materialize(_ )` will then use this initializer, if necessary,
    /// to create an object of this type.
    ///
    /// - Parameter meta: An object that conforms to `ComponentMeta`
    ///   and contains the desired metadata. A `Dictionary` can also be used.
    init?(meta: ComponentMeta)
}

extension ExpressibleByComponentMeta {
    
    /// Materializes a ComponentMeta into this type
    ///
    /// - Parameter meta: A representation of the meta object to materialize (e.g. a dictionary)
    ///   or an already materialized meta object.
    /// - Returns: A materialized `ExpressibleByComponentMeta` object if the input represents correctly
    ///   the object to be materialized. 
    /// - Note: This will return nil when `meta` is nil or 
    ///   will return the same `meta` object when `meta` is already a `Self` type.
    public static func materialize(_ meta: ComponentMeta?) -> Self? {
        guard let meta = meta else {
            return nil
        }
        
        if let meta = meta as? Self {
            return meta
        }
        
        return Self(meta: meta)
    }
}

extension Dictionary: ComponentMeta {
    
    /// Forwards the subscript to Dictionary's implementation
    ///
    /// - Parameter key: the key of the value to retreive
    @available(swift, obsoleted: 3.1)
    public subscript(key: String) -> Any? {
        if let key = key as? Key {
            return self[key]
        }
        return nil
    }
}

/// Aggregates multiple metas togheter
public struct ZipMeta: ComponentMeta {
    let metas: [ComponentMeta]
    
    /// Initialize a zip meta from multiple `ComponentMeta`
    ///
    /// - Parameter metas: A list of `ComponentMeta`s
    public init(_ metas: ComponentMeta...) {
        self.metas = metas
    }
    
    /// Forward the subscript to the zipped metas in the order they where provided
    ///
    /// - Parameter key: The key of the meta to retreive
    public subscript(key: String) -> Any? {
        for meta in metas {
            if let result = meta[key] {
                return result
            }
        }
        
        return nil
    }
}
