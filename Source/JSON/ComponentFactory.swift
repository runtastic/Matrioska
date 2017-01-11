//
//  ComponentJSONFactory.swift
//  Matrioska
//
//  Created by Mathias Aichinger on 11/01/2017.
//  Copyright © 2017 runtastic. All rights reserved.
//

import Foundation

public protocol ComponentFactory {
    func produce(children: [Component],
                 meta: ComponentMeta?) -> Component?
    func typeName() -> String
}
