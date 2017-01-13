//
//  JSONReaderTests.swift
//  Matrioska
//
//  Created by Joan Romano on 12/01/17.
//  Copyright © 2017 runtastic. All rights reserved.
//

import XCTest
import Quick
import Nimble
@testable import Matrioska

class JSONReaderTests: QuickSpec {
    
    override func spec() {
     
        describe("From Data") {
            context("when reading from valid data") {
                let data = "{\"structure\": {\"id\": \"tabbar\", \"type\": \"tabbar\", \"meta\": { \"default_tab_id\": \"main_tab\" }}}".data(using: .utf8)!
                let jsonObject = try! JSONReader.jsonObject(from: data)
                
                it("returns a valid JSON object") {
                    XCTAssertNotNil(jsonObject)
                    XCTAssertNotNil(jsonObject!["structure"])
                    let structure = jsonObject!["structure"] as? JSONObject
                    XCTAssertNotNil(structure!["id"])
                }
            }
            
            context("when reading from invalid data") {
                let data = "{\"structure\": {\"id\": \"tabbar\", \"type\": \"tabbar\", \"meta\": { \"default_tab_id\": \"main_tab\" }}}}".data(using: .utf8)!
                
                it("throws") {
                    let faultyJsonObject = { _ = try! JSONReader.jsonObject(from: data) }
                    
                    expect(faultyJsonObject()).to(throwAssertion())
                }
            }
        }
        
        describe("From file") {
            
            context("when reading from an existing valid file") {
                let jsonObject = try! JSONReader.jsonObject(from: "app_structure", bundle: Bundle(for: JSONReaderTests.self))
                
                it("returns a valid JSONObject") {
                    XCTAssertNotNil(jsonObject)
                    XCTAssertNotNil(jsonObject!["structure"])
                    let structure = jsonObject!["structure"] as? JSONObject
                    XCTAssertNotNil(structure!["type"])
                    XCTAssertNotNil(structure!["meta"])
                }
            }
            
            context("when reading from an invalid file path") {
                let jsonObject = try! JSONReader.jsonObject(from: "asdf", bundle: Bundle(for: JSONReaderTests.self))
                
                it("returns nil") {
                    XCTAssertNil(jsonObject)
                }
            }
            
            context("when reading from an existing invalid file") {
                it("throws") {
                    let faultyJsonObject = { _ = try! JSONReader.jsonObject(from: "invalid", bundle: Bundle(for: JSONReaderTests.self)) }
                    
                    expect(faultyJsonObject()).to(throwAssertion())
                }
            }
        }
        
    }
    
}
