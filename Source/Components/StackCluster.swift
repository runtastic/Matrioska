//
//  StackCluster.swift
//  Matrioska
//
//  Created by Alex Manzella on 16/11/16.
//  Copyright © 2016 runtastic. All rights reserved.
//

import Foundation

extension ClusterLayout {
    
    /// Stack component configuration.
    public struct StackConfig: ExpressibleByComponentMeta {
        /// The title of the stack view, nil by default.
        public let title: String?
        /// The spacing of the components inside the stack. Default 10.
        public let spacing: CGFloat
        /// The axis of the stack view, by default is vertical.
        /// A stack with a horizontal axis is a row of arrangedSubviews,
        /// and a stack with a vertical axis is a column of arrangedSubviews.
        public let axis: UILayoutConstraintAxis
        /// Defines if the arranged subviews should preserve the parent width
        /// or their own intrinsicContentSize. Default false.
        public let preserveParentWidth: Bool
        /// The backgroundColor of the stackView, Default is white.
        public let backgroundColor: UIColor

        /// Initialize a stack configuration from a `ComponentMeta`
        /// Used to materialzie `StackConfig` if the meta contains the values needed.
        /// The default values will be used where `meta` doesn't have a valid ones.
        ///
        /// - Parameter meta: A meta object
        public init?(meta: ComponentMeta) {
            let title = meta["title"] as? String
            let spacing = (meta["spacing"] as? NSNumber)?.floatValue
            let preserveParentWidth = meta["preserve_parent_width"] as? Bool
            var axis = UILayoutConstraintAxis.vertical
            if let orientationRawValue = meta["orientation"] as? String,
                let orientation = Orientation(rawValue: orientationRawValue) {
                axis = orientation.layoutConstraintAxis
            }
            let hexString = meta["background_color"] as? String
            let backgroundColor = hexString.flatMap { UIColor(hexString: $0) }
            
            self.init(
                title: title,
                spacing: spacing.map { CGFloat($0) },
                axis: axis,
                preserveParentWidth: preserveParentWidth,
                backgroundColor: backgroundColor
            )
        }
        
        /// Creates a new stack configuration
        ///
        /// - Parameters:
        ///   - title: The title of the stack view, nil by default.
        ///   - spacing: The spacing of the components inside the stack. Default 10.
        ///   - axis: The axis of the stack view, by default is vertical.
        ///   - preserveParentWidth: Defines the arranged subviews should preserve the parent width
        ///     or their own intrinsicContentSize. Default false.
        ///   - backgroundColor: The backgroundColor of the stackView, Default is white.
        public init(title: String? = nil,
                    spacing: CGFloat? = nil,
                    axis: UILayoutConstraintAxis? = nil,
                    preserveParentWidth: Bool? = nil,
                    backgroundColor: UIColor? = nil) {
            self.title = title
            self.spacing = spacing ?? 10
            self.axis = axis ?? .vertical
            self.preserveParentWidth = preserveParentWidth ?? false
            self.backgroundColor = backgroundColor ?? .white
        }
    }

    /// A stack cluster component.
    /// It arranges its children views in a vertical or horizontal stack, configured with the meta.
    ///
    /// - Parameters:
    ///   - children: The children components
    ///   - meta: Should represent `StackConfig` object to configure the stack view
    /// - Returns: A stack component
    public static func stack(children: [Component], meta: ComponentMeta?) -> Component {
        return Component.cluster(viewBuilder: stackBuilder,
                                 children: children,
                                 meta: meta)
    }
    
    private static func stackBuilder(_ children: [Component],
                                     _ meta: ComponentMeta?) -> UIViewController? {
        let stackViewController = StackViewController(configuration: StackConfig.materialize(meta))
        stackViewController.add(children: children)
        return stackViewController
    }
}

fileprivate extension StackViewController {
    
    func add(children: [Component]) {
        for child in children {
            guard let viewController = child.viewController() else {
                continue
            }
            add(child: viewController)
        }
    }
}
