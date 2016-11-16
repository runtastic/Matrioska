//
//  Component.swift
//  Matrioska
//
//  Created by Alex Manzella on 10/11/16.
//  Copyright © 2016 runtastic. All rights reserved.
//

import Foundation

/// Represent a UI `Component`
/// `Component`s can be nested and contain other components
public indirect enum Component {

    /// A closure to build a ViewController. Can receive metadata for additional configurations
    public typealias ViewBuilder = (_ meta: Any?) -> UIViewController?
    /// A closure to build a Wrapper ViewController.
    /// The view is responsible to wrap and display it's child component.
    /// Can receive metadata for additional configurations
    public typealias WrapperBuilder = (_ child: Component, _ meta: Any?) -> UIViewController?
    /// A closure to build a Cluster ViewController.
    /// The view is responsible to display and layout its children components.
    /// Can receive metadata for additional configurations
    public typealias ClusterBuilder = (_ children: [Component], _ meta: Any?) -> UIViewController?

    /// Represents any `UIViewController`.
    /// The view should use AutoLayout to specify its `intrinsicContentSize`.
    case view(builder: ViewBuilder, meta: Any?)
    /// Represents a view with only one child (a `Component`).
    /// The view should use AutoLayout to specify its `intrinsicContentSize`.
    /// You can see it as a special cluster or as a special view.
    /// It’s responsible to display its child’s view.
    case wrapper(builder: WrapperBuilder, child: Component, meta: Any?)
    /// Represents a view with children (other `Component`s).
    /// A cluster is responsible of laying out its children’s views.
    /// Since a cluster is itself a view it can also contain other clusters.
    case cluster(builder: ClusterBuilder, children: [Component], meta: Any?)

    /// Create a ViewController represented by the `Component`
    ///
    /// - Returns: An optional UIViewController.
    /// The receiver is responsible to handle eventual fallbacks
    public func viewController() -> UIViewController? {
        switch self {
        case let .view(builder, meta):
            return builder(meta)
        case let .wrapper(builder, child, meta):
            return builder(child, meta)
        case let .cluster(builder, children, meta):
            return builder(children, meta)
        }
    }
}
