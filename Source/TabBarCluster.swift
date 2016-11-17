//
//  TabBarCluster.swift
//  Matrioska
//
//  Created by Alex Manzella on 15/11/16.
//  Copyright © 2016 runtastic. All rights reserved.
//

import Foundation

extension ClusterLayout {
    
    /// Tab configuration.
    public struct TabConfig: MaterializableComponentMeta {
        /// The tab name
        public let name: String
        /// The tab icon
        public let iconName: String
        /// Used to locate the icon
        fileprivate let bundle: Bundle
        
        // TODO: docu
        public init?(meta: ComponentMeta) {
            guard let name = meta["name"] as? String else {
                return nil
            }
            guard let iconName = meta["iconName"] as? String else {
                return nil
            }
            
            self.init(name: name, iconName: iconName)
        }
        
        /// Creates a `TabConfig` object
        ///
        /// - Parameters:
        ///   - name: The tab name
        ///   - iconName: The tab icon
        ///   - bundle: An optional bundle where to search for the icon.
        ///     By default the main bundle is used
        public init(name: String, iconName: String, bundle: Bundle = .main) {
            self.name = name
            self.iconName = iconName
            self.bundle = bundle
        }
    }
    
    /// TabBar component configuration.
    public struct TabBarConfig: MaterializableComponentMeta {
        /// The selected index of the tabBar
        public let selectedIndex: Int
        
        // TODO: docu
        public init?(meta: ComponentMeta) {
            guard let selectedIndex = meta["selectedIndex"] as? Int else {
                return nil
            }
            
            self.selectedIndex = selectedIndex
        }
        
        /// Initialize a TabBar config
        ///
        /// - Parameter selectedIndex: The selected index of the tabBar
        public init(selectedIndex: Int) {
            self.selectedIndex = selectedIndex
        }
    }
    
    /// A tabBar cluster component. Will use its children metas to configure the tabBar.
    ///
    /// - Parameters:
    ///   - children: Each children should have a meta representing `TabConfig`
    ///   - meta: An optional TabBarConfig to configure the tabBar component.
    ///   - bundle: An optional bundle to retreive icon defined in TabBarConfig.
    ///             Overrides TabBarConfig's own bundle.
    /// - Returns: A tabBar cluster component
    public static func tabBar(children: [Component],
                              meta: ComponentMeta?,
                              bundle: Bundle? = nil) -> Component {
        
        return Component.cluster(builder: tabBarBuilder(bundle),
                                 children: children,
                                 meta: meta)
    }
    
    /// A builder for tabBar component that uses partial application
    /// to let us specify the bundle where the images of tabBar items are located
    private static func tabBarBuilder(_ bundle: Bundle?) -> Component.ClusterBuilder {
        
        typealias Tab = (meta: TabConfig, viewController: UIViewController)

        return { (children: [Component], meta: ComponentMeta?) -> UIViewController? in
            
            let tabs: [Tab] = children.flatMap { (child) in
                guard let vc = child.viewController() else {
                    return nil
                }
                
                guard let config = TabConfig.metarialize(child.meta) else {
                    return nil
                }
                
                return (config, vc)
            }
            
            let tabBarController = UITabBarController()
            tabBarController.viewControllers = tabs.flatMap { $0.viewController }
            
            if let items = tabBarController.tabBar.items {
                for (item, tab) in zip(items, tabs) {
                    let meta = tab.meta
                    tab.viewController.title = meta.name
                    item.image = UIImage(named: meta.iconName,
                                         in: bundle ?? meta.bundle,
                                         compatibleWith: nil)
                }
            }
            
            let meta = TabBarConfig.metarialize(meta)
            if let selectedIndex = meta?.selectedIndex, selectedIndex < tabs.count {
                tabBarController.selectedIndex = selectedIndex
            }
            
            return tabBarController
        }
    }
}
