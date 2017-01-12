//
//  JSONReaderTests.swift
//  Matrioska
//
//  Created by Mathias Aichinger on 12/01/2017.
//  Copyright © 2017 runtastic. All rights reserved.
//

import XCTest
@testable import Matrioska

class JSONReaderTests: XCTestCase {
    
    func testReadingJSONFile() {
        let jsonObject = JSONReader.jsonObject(from: "app_structure", bundle: Bundle(for: JSONReaderTests.self))
        XCTAssertNotNil(jsonObject)
        XCTAssertNotNil(jsonObject!["structure"])
        let structure = jsonObject!["structure"] as? JSONObject
        XCTAssertNotNil(structure!["id"])
    }
    
    func testWrongJSONPath() {
        let jsonObject = JSONReader.jsonObject(from: "asdf", bundle: Bundle(for: JSONReaderTests.self))
        XCTAssertNil(jsonObject)
    }
    
    func testInvalidJSON() {
        let jsonObject = JSONReader.jsonObject(from: "invalid", bundle: Bundle(for: JSONReaderTests.self))
        XCTAssertNil(jsonObject)
    }
    
}
