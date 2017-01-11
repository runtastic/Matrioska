//
//  JsonParser.swift
//  Matrioska
//
//  Created by Mathias Aichinger on 11/01/2017.
//  Copyright © 2017 runtastic. All rights reserved.
//

import Foundation

class JsonParser {
    var factories: [String: ComponentFactory] = [:]
    
    func registerFactory(factory: ComponentFactory) {
        factories[factory.typeName()] = factory
    }
    
    func parseJson(json: String) -> Component? {
        return nil
    }
}
