//
//  RuleComponentTests.swift
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
            
            context("when defining a rule component that evaluates to false") {
                let simpleComponent = simpleViewComponent(with: nil)
                let ruleComponent = simpleRuleComponent(evaluating: false, child: simpleComponent)
                
                it("has no view controller") {
                    expect(ruleComponent.viewController()).to(beNil())
                }
                
                it("has his child's meta") {
                    expect(ruleComponent.meta).to(beNil())
                }
            }
            
            context("when defining a rule component that evaluates to true") {
                let simpleComponent = simpleViewComponent(with: ["foo": "bar"])
                let ruleComponent = simpleRuleComponent(evaluating: true, child: simpleComponent)
                
                it("has his child's view controller") {
                    expect(ruleComponent.viewController()).to(beAKindOf(UIViewController.self))
                }
                
                it("has his child's meta") {
                    expect(ruleComponent.meta!["foo"] as? String).to(equal("bar"))
                }
            }
            
        }
        
    }
    
}

fileprivate func simpleRuleComponent(evaluating: Bool, child: Component) -> Component {
    return Component.rule(evaluator: { return evaluating }, component: child)
}

fileprivate func simpleViewComponent(with meta: ComponentMeta?) -> Component {
    return Component.view(builder: { _ in UIViewController() }, meta: meta)
}
