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
    
    /// A simple rule with a `RuleEvaluator`.
    case simple(evaluator: RuleEvaluator)
    
    /// A logical AND rule.
    case and(rules: [Rule])
    
    /// A logical OR rule.
    case or(rules: [Rule])
    
    /// A logical NOT rule.
    case not(rule: Rule)
    
    /// Evaluates the receiver
    ///
    /// - Returns: a boolean value as a result of the evaluation
    public func evaluate() -> Bool {
        switch self {
        case let .simple(evaluator: evaluator):
            return evaluator()
        case let .and(rules: rules):
            return rules.reduce(true) { (evaluation, rule) in
                return evaluation && rule.evaluate()
            }
        case let .or(rules: rules):
            return rules.reduce(false) { (evaluation, rule) in
                return evaluation || rule.evaluate()
            }
        case let .not(rule: rule):
            return !rule.evaluate()
        }
    }
}
