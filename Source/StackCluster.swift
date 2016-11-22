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
    public struct StackConfig: MaterializableComponentMeta {
        /// The name of the stack view
        public let name: String?
        /// The spacing of the components inside the stack. Default 10. Optional.
        public let spacing: CGFloat
        /// The axis of the stack view, by default is vertical. Optional.
        /// A stack with a horizontal axis is a row of arrangedSubviews,
        /// and a stack with a vertical axis is a column of arrangedSubviews.
        public let axis: UILayoutConstraintAxis
        /// Defines if the arranged subviews should preserve the parent width
        /// or their own intrinsicContentSize. Default false. Optional.
        public let preserveParentWidth: Bool
                
        /// Initialize a stack configuration from a `ComponentMeta`
        /// Used to materialzie `StackConfig` if the meta contains the values needed.
        /// The default values will be used where `meta` doesn't have a valid ones.
        ///
        /// - Parameter meta: A meta object
        public init?(meta: ComponentMeta) {
            let name = meta["name"] as? String
            let spacing = (meta["spacing"] as? NSNumber)?.floatValue
            let preserveParentWidth = meta["preserveParentWidth"] as? Bool
            let axisRawValue = meta["axis"] as? Int
            let axis = axisRawValue.flatMap { UILayoutConstraintAxis(rawValue: $0) }
            
            self.init(
                name: name,
                spacing: spacing.map(CGFloat.init),
                axis: axis,
                preserveParentWidth: preserveParentWidth
            )
        }
        
        /// Creates a new stack configuration
        ///
        /// - Parameters:
        ///   - name: The name of the stack view, nil by default. Optional.
        ///   - spacing: The spacing of the components inside the stack. Default 10. Optional.
        ///   - axis: The axis of the stack view, by default is vertical. Optional.
        ///   - preserveParentWidth: Defines the arranged subviews should preserve the parent width
        ///     or their own intrinsicContentSize. Default false. Optional.
        public init(name: String? = nil,
             spacing: CGFloat? = nil,
             axis: UILayoutConstraintAxis? = nil,
             preserveParentWidth: Bool? = nil) {
            
            self.name = name
            self.spacing = spacing ?? 10
            self.axis = axis ?? .vertical
            self.preserveParentWidth = preserveParentWidth ?? false
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
        return Component.cluster(builder: stackBuilder,
                                 children: children,
                                 meta: meta)
    }
    
    private static func stackBuilder(_ children: [Component],
                                     _ meta: ComponentMeta?) -> UIViewController? {
        let stackViewController = StackViewController(configuration: StackConfig.metarialize(meta))
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
            addChildViewController(viewController)
            viewController.didMove(toParentViewController: self)
            stackView.addArrangedSubview(viewController.view)
        }
    }
}
