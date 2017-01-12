//
//  ComponentJSONFactory.swift
//  Matrioska
//
//  Created by Mathias Aichinger on 11/01/2017.
//  Copyright © 2017 runtastic. All rights reserved.
//

import Foundation

/// Represents a factory that can produce components
public protocol ComponentFactory {
    
    /// Produces a component out of a Component array and ComponentMeta
    ///
    /// - Parameters:
    ///   - children: an array of children component
    ///   - meta: a ComponentMeta object
    /// - Returns: An optional Component
    func produce(children: [Component],
                 meta: ComponentMeta?) -> Component?
    
    /// The name that identifies this ComponentFactory type
    ///
    /// - Returns: a string representing this type
    func typeName() -> String
}

extension ComponentFactory {
    
    /// A default implementation that returns a `view` Component with a plain UIViewController
    func produce(children: [Component],
                 meta: ComponentMeta?) -> Component? {
        return Component.view(builder: { _ in UIViewController() }, meta: meta)
    }
    
    /// A default implementation that returns the name of this type
    func typeName() -> String {
        return String(describing: self)
    }
}
