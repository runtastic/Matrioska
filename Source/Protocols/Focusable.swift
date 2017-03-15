//
//  Focusable.swift
//  Matrioska
//
//  Created by Andreas Thenn on 14/03/2017.
//  Copyright © 2017 runtastic. All rights reserved.
//

import Foundation

/** This protocol should be implemented by every UIViewController that has some kind of focus,
 highlight or select method. We want these to be adressable in a more generic way and
 we don't need to care about the actual underlying method that's being called.
 */
protocol Focusable {

    /// A generic method that tries to focus on a given target ViewController.
    /// - Parameters:
    ///   - viewController: The ViewController which should get into focus
    @discardableResult
    func focus(on viewController: UIViewController)
    
}
