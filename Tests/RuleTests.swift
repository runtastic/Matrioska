//
//  RuleTests.swift
//  Matrioska
//
//  Created by Joan Romano on 19/01/17.
//  Copyright © 2017 runtastic. All rights reserved.
//

import XCTest
import Quick
import Nimble
@testable import Matrioska

class RuleComponentTests: QuickSpec {
    
    override func spec() {
        
        describe("Rule Component") {
            
            context("when a simple rule component evaluates to false") {
                let simpleComponent = simpleViewComponent()
                let ruleComponent = simpleRuleComponent(evaluating: false, child: simpleComponent)
                
                it("has no view controller") {
                    expect(ruleComponent.viewController()).to(beNil())
                }
                
                it("has his child's meta") {
                    expect(ruleComponent.meta).to(beNil())
                }
            }
            
            context("when a simple rule component evaluates to true") {
                let simpleComponent = simpleViewComponent(with: ["foo": "bar"])
                let ruleComponent = simpleRuleComponent(evaluating: true, child: simpleComponent)
                
                it("has his child's view controller") {
                    expect(ruleComponent.viewController()).to(beAKindOf(UIViewController.self))
                }
                
                it("has his child's meta") {
                    expect(ruleComponent.meta!["foo"] as? String).to(equal("bar"))
                }
            }
            
            context("when a composed rule component evaluates to true") {
                let rule = Rule.and(left: Rule.not(rule: Rule.simple(evaluator: { false })),
                                    right: Rule.or(left: Rule.simple(evaluator: { false }),
                                                   right: Rule.simple(evaluator: { true })))
                let component = Component.rule(rule: rule, component: simpleViewComponent(with: ["blah": "blah"]))
                
                it("evaluates to true") {
                    expect(rule.evaluate()).to(beTrue())
                }
                
                it("has his child's view controller") {
                    expect(component.viewController()).to(beAKindOf(UIViewController.self))
                }
                
                it("has his child's meta") {
                    expect(component.meta!["blah"] as? String).to(equal("blah"))
                }
            }
            
            context("when a composed rule component evaluates to false") {
                let rule = Rule.not(rule: Rule.and(left: Rule.not(rule: Rule.simple(evaluator: { false })),
                                                   right: Rule.or(left: Rule.simple(evaluator: { false }),
                                                                  right: Rule.simple(evaluator: { true }))))
                let component = Component.rule(rule: rule, component: simpleViewComponent(with: ["one": "two"]))
                
                it("evaluates to false") {
                    expect(rule.evaluate()).to(beFalse())
                }
                
                it("has his child's view controller") {
                    expect(component.viewController()).to(beNil())
                }
                
                it("has his child's meta") {
                    expect(component.meta!["one"] as? String).to(equal("two"))
                }
            }
        }
        
    }
    
}

fileprivate func simpleRuleComponent(evaluating: Bool, child: Component) -> Component {
    return Component.rule(rule: Rule.simple(evaluator: { evaluating }), component: child)
}

fileprivate func simpleViewComponent(with meta: ComponentMeta? = nil) -> Component {
    return Component.view(builder: { _ in UIViewController() }, meta: meta)
}
