//
//  Component.swift
//  Matrioska
//
//  Created by Alex Manzella on 10/11/16.
//  Copyright © 2016 runtastic. All rights reserved.
//

import Foundation

/// Represent a UI component
public indirect enum Component {

    public typealias ViewBuilder = (_ meta: Any?) -> UIViewController
    public typealias WrapperBuilder = (_ child: Component, _ meta: Any?) -> UIViewController
    public typealias ClusterBuilder = (_ children: [Component], _ meta: Any?) -> UIViewController

    /// View
    case view(builder: ViewBuilder, meta: Any?)
    /// Wrapper
    case wrapper(builder: WrapperBuilder, child: Component, meta: Any?)
    /// Cluster
    case cluster(builder: ClusterBuilder, children: [Component], meta: Any?)

    /// Create a child ViewController if possible
    ///
    /// - Returns: a UIViewController
    func childViewController() -> UIViewController? {
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
