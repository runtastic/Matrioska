//
//  ScrollMatcher.swift
//  Matrioska
//
//  Created by Alex Manzella on 16/11/16.
//  Copyright © 2016 runtastic. All rights reserved.
//

import Foundation
import UIKit
import Nimble

func scroll(_ axis: UILayoutConstraintAxis) -> ScrollMatcher {
    return ScrollMatcher(axis: axis)
}

enum ScrollMatcherError: Error {
    case nilScrollView
}

struct ScrollMatcher: Matcher {
    typealias ValueType = UIScrollView
    
    let axis: UILayoutConstraintAxis
    
    private func composeFailureMessage(_ message: FailureMessage, negated: Bool) {
        message.expected = "Expected scrollView"
        let negation = negated ? "not" : ""
        let direction = axis == .vertical ? "vertically" : "horizontally"
        message.to = "to \(negation) scroll \(direction)"
        message.postfixMessage = ""
        message.actualValue = nil
    }
    
    private func canScroll(_ actualExpression: Expression<UIScrollView>) throws -> Bool {
        guard let scrollView = try actualExpression.evaluate() else {
            throw ScrollMatcherError.nilScrollView
        }

        if axis == .vertical {
            return scrollView.contentSize.height > scrollView.bounds.height
        } else {
            return scrollView.contentSize.width > scrollView.bounds.width
        }
    }
    
    func matches(_ actualExpression: Expression<UIScrollView>,
                 failureMessage: FailureMessage) throws -> Bool {
        composeFailureMessage(failureMessage, negated: false)
        return try canScroll(actualExpression)
    }
    
    func doesNotMatch(_ actualExpression: Expression<UIScrollView>,
                      failureMessage: FailureMessage) throws -> Bool {
        composeFailureMessage(failureMessage, negated: true)
        return try !canScroll(actualExpression)
    }
}
