//
//  JSONFactoryTests.swift
//  Matrioska
//
//  Created by Joan Romano on 12/01/17.
//  Copyright © 2017 runtastic. All rights reserved.
//

import XCTest
import Quick
import Nimble
@testable import Matrioska

class JSONFactoryTests: QuickSpec {
    
    let bundle = Bundle(for: JSONFactoryTests.self)
    let jsonFileName = "app_structure"
    
    override func spec() {
        
        let jsonObject = try! JSONReader.jsonObject(from: jsonFileName, bundle: bundle)!
        let json = structure(from: jsonObject)
        
        let tabBarFactory = TabBarClusterFactory()
        let stackFactory = StackClusterFactory()
        let buttonFactory = ButtonFactory()
        let labelFactory = LabelFactory()
        let tableViewFactory = TableViewFactory()
        
        let factories: [ComponentFactory] = [tabBarFactory, stackFactory, buttonFactory, labelFactory, tableViewFactory]
        
        describe("Factories") {
            
            context("when no factories added") {
                let jsonFactory = JSONFactory()
                
                it("has no factories") {
                    expect(jsonFactory.factories.count).to(equal(0))
                }
            }
            
            context("when registering factories") {
                let jsonFactory = JSONFactory()
                let tabBarFactory = TabBarClusterFactory()
                let stackFactory = StackClusterFactory()
                jsonFactory.register(tabBarFactory)
                jsonFactory.register(stackFactory)
                
                it("has the registered factories") {
                    expect(jsonFactory.factories.count).to(equal(2))
                    expect(jsonFactory.factories[tabBarFactory.typeName()]).toNot(beNil())
                    expect(jsonFactory.factories[stackFactory.typeName()]).toNot(beNil())
                }
                
                it("does not have non registered factories") {
                    expect(jsonFactory.factories["foo"]).to(beNil())
                    expect(jsonFactory.factories["bar"]).to(beNil())
                }
            }
            
        }
        
        describe("Produce") {
            
            it("throws an assertion when the JSON object does not have type or id") {
                let jsonFactory = JSONFactory()
                let object = ["foo" : "bar"]
                let faultyProduce = { _ = jsonFactory.produce(from: object) }
                
                expect(faultyProduce()).to(throwAssertion())
            }
            
            context("when no factories are added") {
                let jsonFactorry = JSONFactory()
                
                it("returns nil when trying to produce") {
                    let component = jsonFactorry.produce(from: json)
                    expect(component).to(beNil())
                }
            }
            
            context("when registering some available cluster factories") {
                let jsonFactory = JSONFactory()
                let tabBarFactory = TabBarClusterFactory()
                jsonFactory.register(tabBarFactory)
                let component = jsonFactory.produce(from: json)
                
                it("handles only those cluster components which have registered factories") {
                    expect(component).toNot(beNil())
                    expect(component?.viewController()).to(beAKindOf(UITabBarController.self))
                    expect(component?.children().count).to(equal(0))
                }
            }
            
            context("when registering all available cluster factories") {
                let jsonFactory = JSONFactory()
                jsonFactory.register(tabBarFactory)
                jsonFactory.register(stackFactory)
                let component = jsonFactory.produce(from: json)
                
                it("handles all cluster components") {
                    expect(component).toNot(beNil())
                    expect(component?.viewController()).to(beAKindOf(UITabBarController.self))
                    expect(component?.children().count).to(equal(2))
                }
                
                it("handles all components recursively") {
                    let firstChildren = component!.children().first
                    let secondChildren = component!.children().last
                    
                    expect(firstChildren?.viewController()).to(beAKindOf(StackViewController.self))
                    expect(secondChildren?.viewController()).to(beAKindOf(StackViewController.self))
                }
                
                it("does not handle not registered components") {
                    let firstChildren = component!.children().first
                    let secondChildren = component!.children().last
                    
                    expect(firstChildren?.children().count).to(equal(0))
                    expect(secondChildren?.children().count).to(equal(1))
                }
            }
            
            context("when registering all available factories") {
                let jsonFactory = JSONFactory()
                factories.forEach { jsonFactory.register($0) }
                let component = jsonFactory.produce(from: json)
                
                it("handles all components recursively") {
                    let firstChildren = component!.children().first!
                    let secondChildren = component!.children().last!
                    
                    expect(firstChildren.children().count).to(equal(1))
                    expect(secondChildren.children().count).to(equal(3))
                    expect(firstChildren.children()[0].viewController()).to(beAKindOf(UIViewController.self))
                    expect(secondChildren.children()[1].viewController()).to(beAKindOf(StackViewController.self))
                }
            }
        }
        
    }
    
}

fileprivate class ButtonFactory: ComponentFactory {
    fileprivate func typeName() -> String {
        return "button"
    }
}

fileprivate class LabelFactory: ComponentFactory {
    fileprivate func typeName() -> String {
        return "label"
    }
}

fileprivate class TableViewFactory: ComponentFactory {
    fileprivate func typeName() -> String {
        return "table_view"
    }
}

fileprivate extension Component {
    func children() -> [Component] {
        switch self {
        case .view(builder: _, meta: _):
            return []
        case let .wrapper(builder: _, child: child, meta: _):
            return [child]
        case let .cluster(builder: _, children: children, meta: _):
            return children
        }
    }
}

fileprivate func structure(from jsonObject: JSONObject) -> JSONObject {
    return jsonObject["structure"] as! JSONObject
}
