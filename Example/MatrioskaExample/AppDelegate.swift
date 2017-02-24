//
//  AppDelegate.swift
//  MatrioskaExample
//
//  Created by Alex Manzella on 13/12/16.
//  Copyright © 2016 runtastic. All rights reserved.
//

import UIKit
import Matrioska

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    let rootComponent = ClusterLayout.tabBar(
        children: [
            blankComponent(
                meta: ClusterLayout.TabConfig(title: "First", iconName: "tabIcon")
            ),
            blankComponent(
                meta: ClusterLayout.TabConfig(title: "Second", iconName: "tabIcon")
            ),
            navComponent(child:
                ClusterLayout.stack(
                    children: [
                        tileComponent(meta: TileConfig(text: "One", color: .red)),
                        tileComponent(meta: TileConfig(text: "Two", color: .green)),
                        ClusterLayout.stack(
                            children: [
                                tileComponent(meta: TileConfig(text: "A", color: .red)),
                                tileComponent(meta: TileConfig(text: "B", color: .green)),
                                tileComponent(meta: TileConfig(text: "C", color: .orange)),
                                tileComponent(meta: TileConfig(text: "D", color: .yellow)),
                                ],
                            meta: ClusterLayout.StackConfig(axis: .horizontal)
                        ),
                        tileComponent(meta: TileConfig(text: "Three", color: .orange)),
                        tileComponent(meta: TileConfig(text: "Four", color: .yellow)),
                    ],
                    meta: ZipMeta(ClusterLayout.TabConfig(title: "Third", iconName: "tabIcon"))
                )
            ),
            blankComponent(
                meta: ClusterLayout.TabConfig(title: "Fourth", iconName: "tabIcon")
            ),
            blankComponent(
                meta: ClusterLayout.TabConfig(title: "Fifth", iconName: "tabIcon")
            ),
        ],
        meta: ClusterLayout.TabBarConfig(selectedIndex: 2)
    )

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = rootComponent.viewController()
        window?.makeKeyAndVisible()
        
        return true
    }
}

private func navComponent(child: Component) -> Component {
    let viewBuilder: Component.WrapperViewBuilder = { (child, meta) -> UIViewController? in
        return child.viewController().map { UINavigationController(rootViewController: $0) }
    }
    
    return Component.wrapper(viewBuilder: viewBuilder, child: child, meta: child.meta)
}

private func blankComponent(meta: ComponentMeta?) -> Component {
    let viewBuilder: Component.SingleViewBuilder = { (meta) in
        let vc = UIViewController()
        vc.view.backgroundColor = .white
        return vc
    }
    return Component.single(viewBuilder: viewBuilder, meta: meta)
}

private func tileComponent(meta: TileConfig) -> Component {
    return Component.single(viewBuilder: TileViewController.init(meta:), meta: meta)
}
