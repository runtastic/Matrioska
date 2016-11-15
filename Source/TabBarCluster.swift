//
//  TabBarCluster.swift
//  Matrioska
//
//  Created by Alex Manzella on 15/11/16.
//  Copyright © 2016 runtastic. All rights reserved.
//

import Foundation

extension ClusterLayout {
    
    /// TabBar component configuration.
    public struct TabConfig {
        /// The tab name
        public let name: String
        /// The tab icon
        public let iconName: String
        /// Used to locate the icon
        fileprivate let bundle: Bundle
        
        fileprivate init?(meta: Any?, bundle: Bundle = .main) {
            
            if let meta = meta as? TabConfig {
                self = meta
                return
            }
            
            guard let meta = meta as? [String: Any] else {
                return nil
            }
            guard let name = meta["name"] as? String else {
                return nil
            }
            guard let iconName = meta["iconName"] as? String else {
                return nil
            }
            
            self.name = name
            self.iconName = iconName
            self.bundle = bundle
        }
        
        init(name: String, iconName: String, bundle: Bundle = .main) {
            self.name = name
            self.iconName = iconName
            self.bundle = bundle
        }
    }
    
    /// A tabBar cluster component. Will use its children metas to configure the tabBar.
    ///
    /// - Parameters:
    ///   - children: Each children should have a meta representing `TabConfig`
    ///   - meta: An optional integer to represent the selected index.
    ///   - bundle: An optional bundle to retreive icon defined in TabBarConfig.
    ///             Overrides TabBarConfig's own bundle.
    /// - Returns: A tabBar cluster component
    public static func tabBar(children: [Component],
                              meta: Any?,
                              bundle: Bundle? = nil) -> Component {
        
        return Component.cluster(builder: tabBarBuilder(bundle),
                                 children: children,
                                 meta: meta)
    }
    
    /// A builder for tabBar component that uses partial application
    /// to let us specify the bundle where the images of tabBar items are located
    private static func tabBarBuilder(_ bundle: Bundle?) -> Component.ClusterBuilder {
        
        typealias Tab = (meta: TabConfig, viewController: UIViewController)

        return { (children: [Component], meta: Any?) -> UIViewController? in
            
            let tabs: [Tab] = children.flatMap { (child) in
                guard let vc = child.viewController() else {
                    return nil
                }
                
                guard let config = TabConfig(meta: child.meta) else {
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
            
            if let selectedIndex = meta as? Int, selectedIndex < tabs.count {
                tabBarController.selectedIndex = selectedIndex
            }
            
            return tabBarController
        }
    }
}
