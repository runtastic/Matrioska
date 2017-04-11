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
                id: "first",
                meta: ClusterLayout.TabConfig(title: "First", iconName: "tabIcon")
            ),
            blankComponent(
                id: "second",
                meta: ClusterLayout.TabConfig(title: "Second", iconName: "tabIcon")
            ),
            navComponent(child:
                ClusterLayout.stack(
                    children: [
                        tileComponent(id: "one", meta: TileConfig(text: "One", color: .red)),
                        tileComponent(id: "two", meta: TileConfig(text: "Two", color: .green)),
                        ClusterLayout.stack(
                            children: [
                                tileComponent(id: "A", meta: TileConfig(text: "A", color: .red)),
                                tileComponent(id: "B", meta: TileConfig(text: "B", color: .green)),
                                tileComponent(id: "C", meta: TileConfig(text: "C", color: .orange)),
                                tileComponent(id: "D", meta: TileConfig(text: "D", color: .yellow))
                                ],
                            id: nil,
                            meta: ClusterLayout.StackConfig(axis: .horizontal)
                        ),
                        tileComponent(id: "three", meta: TileConfig(text: "Three", color: .orange)),
                        tileComponent(id: "four", meta: TileConfig(text: "Four", color: .yellow))
                    ],
                    id: nil,
                    meta: ZipMeta(ClusterLayout.TabConfig(title: "Third", iconName: "tabIcon"))
                )
            ),
            blankComponent(
                id: "fourth",
                meta: ClusterLayout.TabConfig(title: "Fourth", iconName: "tabIcon")
            ),
            blankComponent(
                id: "fifth",
                meta: ClusterLayout.TabConfig(title: "Fifth", iconName: "tabIcon")
            )
        ],
        id: nil,
        meta: ClusterLayout.TabBarConfig(selectedIndex: 2)
    )

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = rootComponent.viewController()
        window?.makeKeyAndVisible()
        
        return true
    }
}

private func navComponent(child: Component) -> Component {
    let viewBuilder: Component.WrapperViewBuilder = { (child, id, meta) -> UIViewController? in
        return child.viewController().map { UINavigationController(rootViewController: $0) }
    }
    
    return Component.wrapper(viewBuilder: viewBuilder, child: child, id: nil, meta: child.meta)
}

private func blankComponent(id: String?, meta: ComponentMeta?) -> Component {
    let viewBuilder: Component.SingleViewBuilder = { (meta) in
        let vc = UIViewController()
        vc.view.backgroundColor = .white
        return vc
    }
    return Component.single(viewBuilder: viewBuilder, id: id, meta: meta)
}

private func tileComponent(id: String?, meta: TileConfig) -> Component {
    return Component.single(viewBuilder: TileViewController.init(id:meta:), id: id, meta: meta)
}
