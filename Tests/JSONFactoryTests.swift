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
        
        let viewBuilder: JSONFactory.ViewFactoryBuilder = { (meta: ComponentMeta?) in
            Component.view(builder: { _ in UIViewController() }, meta: meta)
        }
        let tabBarBuilder: JSONFactory.ClusterFactoryBuilder = { (children, meta) in
            ClusterLayout.tabBar(children: children, meta: meta)
        }
        let navigationBuilder: JSONFactory.WrapperFactoryBuilder = { (child, meta) in
            Component.wrapper(builder: { _ in UINavigationController() }, child: child, meta: meta)
        }
        let stackBuilder: JSONFactory.ClusterFactoryBuilder = ClusterLayout.stack
        
        describe("Component from builder factories") {
            
            it("throws an assertion when the JSON object does not have mandatory keys") {
                let jsonFactory = JSONFactory()
                
                expect { try jsonFactory.component(from: ["foo": "bar"]) }.to(throwError())
                expect { try jsonFactory.component(from: ["id": "bar"]) }.to(throwError())
            }
            
            context("when no factories are added") {
                let jsonFactorry = JSONFactory()
                
                it("returns nil when trying to get a component") {
                    let component = try! jsonFactorry.component(from: json)
                    expect(component).to(beNil())
                }
            }
            
            context("when registering some available cluster factories") {
                let jsonFactory = JSONFactory()
                jsonFactory.register(with: "tabbar", factoryBuilder: tabBarBuilder)
                let component = try! jsonFactory.component(from: json)
                
                it("handles only those cluster components which have registered factories") {
                    expect(component).toNot(beNil())
                    expect(component?.viewController()).to(beAKindOf(UITabBarController.self))
                    expect(component?.children().count).to(equal(0))
                }
            }
            
            context("when registering all available cluster factories") {
                let jsonFactory = JSONFactory()
                jsonFactory.register(with: "tabbar", factoryBuilder: tabBarBuilder)
                jsonFactory.register(with: "stack", factoryBuilder: stackBuilder)
                let component = try! jsonFactory.component(from: json)
                
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
                
                jsonFactory.register(with: "tabbar", factoryBuilder: tabBarBuilder)
                jsonFactory.register(with: "stack", factoryBuilder: stackBuilder)
                jsonFactory.register(with: "navigation", factoryBuilder: navigationBuilder)
                jsonFactory.register(with: "button", factoryBuilder: viewBuilder)
                jsonFactory.register(with: "label", factoryBuilder: viewBuilder)
                jsonFactory.register(with: "table_view", factoryBuilder: viewBuilder)
                
                let component = try! jsonFactory.component(from: json)
                
                it("handles all components recursively") {
                    let firstChildren = component!.children()[0]
                    let secondChildren = component!.children()[1]
                    let thirdChildren = component!.children()[2]

                    expect(firstChildren.meta!["icon_name"] as? String).to(equal("history_tab_icon"))
                    expect(firstChildren.meta!["title"] as? String).to(equal("history_title"))
                    expect(secondChildren.meta!["icon_name"] as? String).to(equal("main_tab_icon"))
                    expect(secondChildren.meta!["title"] as? String).to(equal("main_tab_title"))
                    
                    expect(component?.children().count).to(equal(3))
                    expect(secondChildren.children().count).to(equal(3))
                    expect(thirdChildren.children().count).to(equal(1))
                    expect(firstChildren.children()[0].viewController()).to(beAKindOf(UIViewController.self))
                    expect(secondChildren.children()[1].viewController()).to(beAKindOf(StackViewController.self))
                }
                
                it("does not handle registered wrapper builders with no children") {
                    let firstChildren = component!.children()[0]
                    
                    expect(firstChildren.children().count).to(equal(1))
                }
                
                it("handles registered wrapper builders with views") {
                    let thirdChildren = component!.children()[2]
                    
                    expect(thirdChildren.viewController()).to(beAKindOf(UINavigationController.self))
                    expect(thirdChildren.children()[0].viewController()).to(beAKindOf(UIViewController.self))
                }
            }
        }
        
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
