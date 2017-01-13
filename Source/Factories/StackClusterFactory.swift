//
//  StackClusterFactory.swift
//  Matrioska
//
//  Created by Mathias Aichinger on 11/01/2017.
//  Copyright © 2017 runtastic. All rights reserved.
//

import Foundation

extension ClusterFactory {
    
    /// A concrete ComponentFactory which produces a stack cluster component
    public final class StackClusterFactory: ComponentFactory {
        public func produce(children: [Component],
                            meta: ComponentMeta?) -> Component? {
            return ClusterLayout.stack(children: children, meta: meta)
        }
        
        public func typeName() -> String {
            return "stack"
        }
    }   
}
