//
//  Rule.swift
//  Matrioska
//
//  Created by Joan Romano on 19/01/17.
//  Copyright © 2017 runtastic. All rights reserved.
//

import Foundation

/// A `Rule` which is used to evaluate the visibility of a `Component`
public indirect enum Rule {
    
    /// A closure type used by the receiver's evaluator
    public typealias RuleEvaluator = () -> Bool
    
    /// A simple rule.
    case simple(evaluator: RuleEvaluator)
    
    /// A logical AND rule.
    case and(left: Rule, right: Rule)
    
    /// A logical OR rule.
    case or(left: Rule, right: Rule)
    
    /// A logical NOT rule.
    case not(rule: Rule)
    
    /// Evaluates the receiver
    ///
    /// - Returns: a boolean value as a result of the evaluation
    public func evaluate() -> Bool {
        switch self {
        case let .simple(evaluator: evaluator):
            return evaluator()
        case let .and(left: leftRule, right: rightRule):
            return leftRule.evaluate() && rightRule.evaluate()
        case let .or(left: leftRule, right: rightRule):
            return leftRule.evaluate() || rightRule.evaluate()
        case let .not(rule: rule):
            return !rule.evaluate()
        }
    }
}
