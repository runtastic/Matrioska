//
//  ComponentMetaTests.swift
//  Matrioska
//
//  Created by Alex Manzella on 17/11/16.
//  Copyright © 2016 runtastic. All rights reserved.
//

import XCTest
import Quick
import Nimble
import Nimble_Snapshots
import FBSnapshotTestCase
import Matrioska

class ComponentMetaTests: QuickSpec {
    
    override func spec() {
        describe("ComponentMeta") {
            
            context("when it doesn't provides a custom subscript") {
                it("should by default return the value of its properties") {
                    let meta = DummyMeta(value: "foo")
                    expect(meta["property1"] as? String) == "foo"
                    expect(meta["property1"] is String).to(beTrue())
                    expect(meta["property2"] as? String) == "notMaterialized"
                    expect(meta["property3"] as? String) == "notMaterialized"
                }
                
                it("should return nil for optional properties of ComponentMeta") {
                    // Mirror might return a Optional<Optional<T>>
                    let meta = DoubleOptionalRisk(title: nil)
                    expect(meta["title"]).to(beNil())
                }
                
                it("should return nil if the property is not found") {
                    let meta = DummyMeta(value: "foo")
                    expect(meta["foo"]).to(beNil())
                }
            }
            
            context("when it provides a custom subscript") {
                it("should not use the default implementation") {
                    let meta = AnyMeta()
                    expect(meta["whateverIWant"] as? String) == "whateverIWant"
                }
            }
            
            context("when is Materializable") {
                it("shold not materialize the meta if it's already materialized") {
                    let meta: ComponentMeta = DummyMeta(value: "test")
                    expect(DummyMeta.materialize(meta)).to(be(meta))
                }
                
                it("shold not materialize the meta if is nil") {
                    let meta: ComponentMeta? = nil
                    expect(DummyMeta.materialize(meta)).to(beNil())
                }
                
                it("shold materialize the meta if the content is correct") {
                    let metaRepresentation = ["property1": "foo"]
                    let meta = DummyMeta.materialize(metaRepresentation)
                    expect(meta?["property1"] as? String) == "foo"
                    expect(meta?["property2"] as? String) == "materialized"
                    expect(meta?["property3"] as? String) == "materialized"
                }
            }
        }
        
        describe("Dictioanry") {
            it("should get the values from the provided dictionary") {
                let meta = ["foo1": "bar1", "foo2": "bar2"]
                expect(meta["foo1"]) == "bar1"
                expect(meta["foo2"]) == "bar2"
            }
            
            it("should return always nil if the key is not the same type of the dictionary Key") {
                let meta: [Int: String] = [1: "bar1"]
                expect(meta["foo"]).to(beNil())
            }
        }
        
        describe("ZipMeta") {
            it("should join multiple metas and allow you to retreive their content") {
                let meta1 = ["foo1": "bar1"]
                let meta2 = ["foo2": "bar2"]
                let meta3 = ["foo3": "bar3"]
                
                let zip = ZipMeta(meta1, meta2, meta3)
                expect(zip["foo1"] as? String) == "bar1"
                expect(zip["foo2"] as? String) == "bar2"
                expect(zip["foo3"] as? String) == "bar3"
            }
            
            it("should respect the order of the metas if the keys are overllapping") {
                let meta1 = ["foo": "bar1"]
                let meta2 = ["foo": "bar2"]
                let meta3 = ["foo": "bar3"]
                
                let zip = ZipMeta(meta1, meta2, meta3)
                expect(zip["foo"] as? String) == "bar1"
            }
            
            it("should return nil when key is not matched in any meta") {
                let meta1 = ["foo1": "bar1"]
                let meta2 = ["foo2": "bar2"]

                let zip = ZipMeta(meta1, meta2)
                expect(zip["foo"] as? String).to(beNil())
            }
        }
    }
}

public class DummyMeta: ExpressibleByComponentMeta {
    public let property1: String?
    internal let property2: String
    fileprivate let property3: String
    
    public required init?(meta: ComponentMeta) {
        self.property1 = meta["property1"] as? String
        self.property2 = "materialized"
        self.property3 = "materialized"
    }
    
    public required init(value: String?) {
        self.property1 = value
        self.property2 = "notMaterialized"
        self.property3 = "notMaterialized"
    }
}

struct AnyMeta: ComponentMeta {
    subscript(key: String) -> Any? {
        return key
    }
}

struct DoubleOptionalRisk: ComponentMeta {
    let title: String?
}
