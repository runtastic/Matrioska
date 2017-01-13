//
//  TabBarClusterFactory.swift
//  Matrioska
//
//  Created by Mathias Aichinger on 11/01/2017.
//  Copyright © 2017 runtastic. All rights reserved.
//

import Foundation

extension ClusterFactory {
    
    /// A concrete ComponentFactory which produces a tabBar cluster component
    public final class TabBarClusterFactory: ComponentFactory {
        public func produce(children: [Component],
                            meta: ComponentMeta?) -> Component? {
            return ClusterLayout.tabBar(children: children, meta: meta)
        }
        
        public func typeName() -> String {
            return "tabbar"
        }
    }
}