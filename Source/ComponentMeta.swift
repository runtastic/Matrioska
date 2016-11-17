//
//  ComponentMeta.swift
//  Matrioska
//
//  Created by Alex Manzella on 16/11/16.
//  Copyright © 2016 runtastic. All rights reserved.
//

import Foundation

/// <#Description#>
public protocol ComponentMeta {
    
    /// <#Description#>
    ///
    /// - Parameter key: <#key description#>
    subscript(key: String) -> Any? { get }
}

/// <#Description#>
public protocol MaterializableComponentMeta: ComponentMeta {
    // TODO: docu
    init?(meta: ComponentMeta)
}

extension ComponentMeta {

    /// <#Description#>
    ///
    /// - Parameter key: <#key description#>
    public subscript(key: String) -> Any? {
        let mirror = Mirror(reflecting: self)
        let candidate = mirror.children.first { (child) -> Bool in
            child.label == key
        }
        return candidate?.value
    }
}

extension MaterializableComponentMeta {
    
    /// <#Description#>
    ///
    /// - Returns: <#return value description#>
    public static func metarialize(_ meta: ComponentMeta?) -> Self? {
        guard let meta = meta else {
            return nil
        }
        
        if let meta = meta as? Self {
            return meta
        }
        
        return Self(meta: meta)
    }
}

public struct Meta: ComponentMeta {
    private let dictionary: [String: Any]
    
    /// <#Description#>
    ///
    /// - Parameter dictionary: <#dictionary description#>
    public init(_ dictionary: [String: Any]) {
        self.dictionary = dictionary
    }
    
    /// <#Description#>
    ///
    /// - Parameter key: <#key description#>
    public subscript(key: String) -> Any? {
        return dictionary[key]
    }
}

public struct ZipMeta: ComponentMeta {
    let metas: [ComponentMeta]
    
    /// <#Description#>
    ///
    /// - Parameter metas: <#metas description#>
    public init(_ metas: ComponentMeta...) {
        self.metas = metas
    }
    
    /// <#Description#>
    ///
    /// - Parameter key: <#key description#>
    public subscript(key: String) -> Any? {
        for meta in metas {
            if let result = meta[key] {
                return result
            }
        }
        
        return nil
    }
}
