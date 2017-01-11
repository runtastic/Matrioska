//
//  StackCluster.swift
//  Matrioska
//
//  Created by Mathias Aichinger on 11/01/2017.
//  Copyright © 2017 runtastic. All rights reserved.
//

import Foundation

class StackClusterFactory: ComponentFactory {
    func produce(children: [Component],
                 meta: ComponentMeta?) -> Component? {
        return ClusterLayout.stack(children: children, meta: meta)
    }
    
    func typeName() -> String {
        return "stack"
    }
}
