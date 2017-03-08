//
//  Component.swift
//  Matrioska
//
//  Created by Alex Manzella on 10/11/16.
//  Copyright © 2016 runtastic. All rights reserved.
//

import Foundation

/// Represents a UI `Component`
/// `Component`s can be nested and contain other components.
public indirect enum Component {

    /// A closure to build a `UIViewController` for a single component.
    /// Can receive metadata for additional configuration.
    public typealias SingleViewBuilder = (_ meta: ComponentMeta?) -> UIViewController?
    
    /// A closure to build a `UIViewController` for a wrapper component.
    /// The view is responsible to wrap and display it's child component.
    /// Can receive metadata for additional configuration.
    public typealias WrapperViewBuilder = (
        _ child: Component,
        _ meta: ComponentMeta?
        ) -> UIViewController?
    
    /// A closure to build a `UIViewController` for a cluster component.
    /// The builder can return nil in case the `Component` shouldn't be shown.
    /// For example a `Component` that lacks proper metadata might not be displayable.
    /// The view is responsible to display and layout its children components.
    /// Can receive metadata for additional configuration.
    public typealias ClusterViewBuilder = (
        _ children: [Component],
        _ meta: ComponentMeta?
        ) -> UIViewController?

    /// Represents any `UIViewController`.
    /// The view should use AutoLayout to specify its `intrinsicContentSize`.
    case single(viewBuilder: SingleViewBuilder, meta: ComponentMeta?)
    /// Represents a view with only one child (another `Component`).
    /// The view should use AutoLayout to specify its `intrinsicContentSize`.
    /// You can see it as a special cluster or as a special view.
    /// It’s responsible to display its child’s view.
    case wrapper(viewBuilder: WrapperViewBuilder, child: Component, meta: ComponentMeta?)
    /// Represents a view with children (other `Component`s).
    /// A cluster is responsible of laying out its children’s views.
    /// Since a cluster is itself a view it can also contain other clusters.
    case cluster(viewBuilder: ClusterViewBuilder, children: [Component], meta: ComponentMeta?)
    /// Represents a Component whose visibility is specified
    /// by the evaluation of a `Rule`.
    case rule(rule: Rule, component: Component)

    /// The meta of the component
    public var meta: ComponentMeta? {
        switch self {
        case let .single(_, meta):
            return meta
        case let .wrapper(_, _, meta):
            return meta
        case let .cluster(_, _, meta):
            return meta
        case let .rule(_, child):
            return child.meta
        }
    }
    
    /// Create a ViewController represented by the `Component`
    ///
    /// - Returns: An optional `UIViewController`.
    /// The receiver is responsible to handle eventual fallbacks.
    /// The builder can return nil in case the `Component` shouldn't be shown.
    /// For example a `Component` that lacks proper metadata might not be displayable.
    public func viewController() -> UIViewController? {
        switch self {
        case let .single(builder, meta):
            return builder(meta)
        case let .wrapper(builder, child, meta):
            return builder(child, meta)
        case let .cluster(builder, children, meta):
            return builder(children, meta)
        case let .rule(rule, child):
            return rule.evaluate() ? child.viewController() : nil
        }
    }
}
