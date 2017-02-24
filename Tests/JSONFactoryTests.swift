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
    
    /// This spec tests a set of expected behaviors on `JSONFactory` when creating a
    /// Component from a local JSON file.
    ///
    /// The loaded Component has the following structure:
    ///
    /// [ Cluster.TabBar -> [ AND(["is_gold_member", "is_male"], Cluster.Stack -> [ View,
    ///                                                                            View ]),
    ///                      Cluster.Stack -> [ ("is_male", View),
    ///                                         OR(["is_gold_member", NOT("is_male")], Cluster.Stack),
    ///                                         View ],
    ///                      Wrapper -> [ NOT("is_male", View) ]
    ///                     ]
    /// ]
    override func spec() {
        
        let json = try! JSONReader.jsonObject(from: jsonFileName, bundle: bundle)!
        
        let viewBuilder: JSONFactory.SingleBuilder = { (meta: ComponentMeta?) in
            Component.single(viewBuilder: { _ in UIViewController() }, meta: meta)
        }
        let tabBarBuilder: JSONFactory.ClusterBuilder = { (children, meta) in
            ClusterLayout.tabBar(children: children, meta: meta)
        }
        let navigationBuilder: JSONFactory.WrapperBuilder = { (child, meta) in
            let navigation: UINavigationController
            if let vc = child.viewController() {
                navigation = UINavigationController(rootViewController: vc)
            } else {
                navigation = UINavigationController()
            }
            return Component.wrapper(viewBuilder: { _ in navigation }, child: child, meta: meta)
        }
        let stackBuilder: JSONFactory.ClusterBuilder = ClusterLayout.stack
        let trueRuleBuilder: JSONFactory.RuleBuilder = { true }
        let falseRuleBuilder: JSONFactory.RuleBuilder = { false }
        
        describe("Component from builder factories") {
            
            it("throws an assertion when the JSON object does not have mandatory keys") {
                let jsonFactory = JSONFactory()
                
                expect { try jsonFactory.makeComponent(json: ["foo": "bar"]) }.to(throwError())
                expect { try jsonFactory.makeComponent(json: ["structure": ["foo": "bar"]]) }.to(throwError())
                expect { try jsonFactory.makeComponent(json: ["structure": ["id": "bar"]]) }.to(throwError())
            }
            
            context("when no factories are added") {
                let jsonFactory = JSONFactory()
                
                it("returns nil when trying to get a component") {
                    let component = try! jsonFactory.makeComponent(json: json)
                    expect(component).to(beNil())
                }
            }
            
            context("when registering some available cluster factories") {
                let jsonFactory = JSONFactory()
                jsonFactory.register(builder: tabBarBuilder, forType: "tabbar")
                let component = try! jsonFactory.makeComponent(json: json)
                
                it("handles only those cluster components which have registered factories") {
                    expect(component).toNot(beNil())
                    expect(component?.viewController()).to(beAKindOf(UITabBarController.self))
                    expect(component?.children().count).to(equal(0))
                }
            }
            
            context("when registering all available cluster factories") {
                let jsonFactory = JSONFactory()
                jsonFactory.register(builder: tabBarBuilder, forType: "tabbar")
                jsonFactory.register(builder: stackBuilder, forType: "stack")
                let component = try! jsonFactory.makeComponent(json: json)
                
                it("handles all cluster components") {
                    expect(component).toNot(beNil())
                    expect(component?.viewController()).to(beAKindOf(UITabBarController.self))
                    expect(component?.children().count).to(equal(2))
                }
                
                it("handles all components recursively") {
                    let firstChild = component!.children().first
                    let secondChild = component!.children().last
                    
                    expect(firstChild?.viewController()).to(beAKindOf(StackViewController.self))
                    expect(secondChild?.viewController()).to(beAKindOf(StackViewController.self))
                }
                
                it("does not handle not registered components") {
                    let firstChild = component!.children().first
                    let secondChild = component!.children().last
                    
                    expect(firstChild?.children().count).to(equal(0))
                    expect(secondChild?.children().count).to(equal(1))
                }
            }
            
            context("when registering all available factories") {
                let jsonFactory = JSONFactory()
                
                jsonFactory.register(builder: tabBarBuilder, forType: "tabbar")
                jsonFactory.register(builder: stackBuilder, forType: "stack")
                jsonFactory.register(builder: navigationBuilder, forType: "navigation")
                jsonFactory.register(builder: viewBuilder, forType: "button")
                jsonFactory.register(builder: viewBuilder, forType: "label")
                jsonFactory.register(builder: viewBuilder, forType: "table_view")
                
                let component = try! jsonFactory.makeComponent(json: json)
                
                it("handles all components recursively") {
                    let firstChild = component!.children()[0]
                    let secondChild = component!.children()[1]
                    let thirdChild = component!.children()[2]
                    let childViewControllers = component!.viewController()!.childViewControllers
                    
                    expect(firstChild.meta!["icon_name"] as? String).to(equal("history_tab_icon"))
                    expect(firstChild.meta!["title"] as? String).to(equal("history_title"))
                    expect(secondChild.meta!["icon_name"] as? String).to(equal("main_tab_icon"))
                    expect(secondChild.meta!["title"] as? String).to(equal("main_tab_title"))
                    
                    expect(component?.children().count).to(equal(3))
                    expect(secondChild.children().count).to(equal(3))
                    expect(thirdChild.children().count).to(equal(1))
                    expect(firstChild.children()[0].viewController()).to(beAKindOf(UIViewController.self))
                    expect(secondChild.children()[1].viewController()).to(beAKindOf(StackViewController.self))
                    
                    expect(childViewControllers.count).to(equal(3))
                    expect(childViewControllers[0].childViewControllers.count).to(equal(1))
                    expect(childViewControllers[1].childViewControllers.count).to(equal(3))
                    expect(childViewControllers[2].childViewControllers.count).to(equal(1))
                }
                
                it("does not handle registered wrapper builders with no children") {
                    let firstChild = component!.children()[0]
                    
                    expect(firstChild.children().count).to(equal(1))
                }
                
                it("handles registered wrapper builders with views") {
                    let thirdChild = component!.children()[2]
                    
                    expect(thirdChild.viewController()).to(beAKindOf(UINavigationController.self))
                    expect(thirdChild.children()[0].viewController()).to(beAKindOf(UIViewController.self))
                }
            }
            
            context("when registering all available factories and rules") {
                let jsonFactory = JSONFactory()
                
                jsonFactory.register(builder: tabBarBuilder, forType: "tabbar")
                jsonFactory.register(builder: stackBuilder, forType: "stack")
                jsonFactory.register(builder: navigationBuilder, forType: "navigation")
                jsonFactory.register(builder: viewBuilder, forType: "button")
                jsonFactory.register(builder: viewBuilder, forType: "label")
                jsonFactory.register(builder: viewBuilder, forType: "table_view")
                jsonFactory.register(builder: falseRuleBuilder, forType: "is_male")
                jsonFactory.register(builder: trueRuleBuilder, forType: "is_gold_member")
                
                let component = try! jsonFactory.makeComponent(json: json)
                
                it("handles all components recursively and evaluates the rules") {
                    let firstChild = component!.children()[0]
                    let secondChild = component!.children()[1]
                    let thirdChild = component!.children()[2]
                    let childViewControllers = component!.viewController()!.childViewControllers
                    
                    expect(firstChild.meta!["icon_name"] as? String).to(equal("history_tab_icon"))
                    expect(firstChild.meta!["title"] as? String).to(equal("history_title"))
                    expect(secondChild.meta!["icon_name"] as? String).to(equal("main_tab_icon"))
                    expect(secondChild.meta!["title"] as? String).to(equal("main_tab_title"))
                    
                    expect(component?.children().count).to(equal(3))
                    expect(secondChild.children().count).to(equal(3))
                    expect(thirdChild.children().count).to(equal(1))
                    expect(firstChild.children()[0].viewController()).to(beAKindOf(UIViewController.self))
                    expect(secondChild.children()[1].viewController()).to(beAKindOf(StackViewController.self))
                    
                    expect(childViewControllers.count).to(equal(2))
                    expect(childViewControllers[0].childViewControllers.count).to(equal(2))
                    expect(childViewControllers[1].childViewControllers.count).to(equal(1))
                }
                
                it("returns a component with no rule when the JSON object has a rule with invalid JSON") {
                    let jsonFactory = JSONFactory()
                    jsonFactory.register(builder: tabBarBuilder, forType: "tabbar")
                    let component = try! jsonFactory.makeComponent(json: ["structure": ["type": "tabbar",
                                                                                        "rule": JSONObject()]])
                    
                    switch component! {
                    case .rule(_, _):
                        fail("it's a rule Component and it should not")
                    default:
                        break
                    }
                }
            }
        }
        
    }
}

fileprivate extension Component {
    func children() -> [Component] {
        switch self {
        case .single(viewBuilder: _, meta: _):
            return []
        case let .wrapper(viewBuilder: _, child: child, meta: _):
            return [child]
        case let .cluster(viewBuilder: _, children: children, meta: _):
            return children
        case let .rule(_, child):
            return child.children()
        }
    }
}
