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
        
        fdescribe("Rule Component") {
            
            it("returns false when the rule evaluates to false") {
                let rule = Rule.simple(false)
                
                expect(rule.evaluate()).to(beFalse())
            }
            
            it("returns true when the rule evaluates to true") {
                let rule = Rule.simple(true)
                
                expect(rule.evaluate()).to(beTrue())
            }
            
            it("returns true when a composed rule evaluates to true") {
                let rule = Rule.and(rules: [Rule.not(rule: Rule.simple(false)),
                                            Rule.or(rules: [Rule.simple(false),
                                                            Rule.simple(true),
                                                            Rule.simple(false)
                                                           ])
                                           ])
                
                expect(rule.evaluate()).to(beTrue())
            }
            
            it("returns false when a composed rule evaluates to false") {
                let rule = Rule.not(rule: Rule.and(rules: [Rule.not(rule: Rule.simple(false)),
                                                           Rule.or(rules: [Rule.simple(false),
                                                                          Rule.simple(true)
                                                                          ]),
                                                           Rule.simple(true)
                                                          ]))
                
                expect(rule.evaluate()).to(beFalse())
            }
        }
        
    }
    
}

extension Rule {
    fileprivate static func simple(_ boolValue: Bool) -> Rule {
        return Rule.simple(evaluator: { boolValue })
    }
}
