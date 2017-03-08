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

    /**/

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        
        let factory = JSONFactory()
        
        let tabBarBuilder: JSONFactory.ClusterBuilder = { (children, meta) in
            ClusterLayout.tabBar(children: children, meta: meta)
        }
        
        let stackBuilder: JSONFactory.ClusterBuilder = { (children, meta) in
            ClusterLayout.stack(children: children, meta: meta)
        }
        
        let navigationBuilder: JSONFactory.WrapperBuilder = { (child, meta) in
            Component.wrapper(viewBuilder: { (child, meta) in
                guard let vc = child.viewController() else {
                    return nil
                }
                return UINavigationController(rootViewController: vc)
            }, child: child, meta: meta)
        }
        
        let tileBuilder: JSONFactory.SingleBuilder = { (meta) in
            Component.single(viewBuilder: { (meta) -> UIViewController? in
                    TileViewController.init(meta: TileConfig.materialize(meta))
                }, meta: meta)
        }
        
        let matrioskaCodeBuilder: JSONFactory.SingleBuilder = { (meta) in
            Component.single(viewBuilder: {_ in 
                return MatrioskaCodeViewController()
            }, meta: meta)
        }
        
        factory.register(builder: tabBarBuilder, forType: "tabbar")
        factory.register(builder: stackBuilder, forType: "stack")
        factory.register(builder: navigationBuilder, forType: "navigation")
        factory.register(builder: tileBuilder, forType: "tile")
        factory.register(builder: matrioskaCodeBuilder, forType: "matrioska")
        
        do {
            if let json = try JSONReader.jsonObject(from: "app_structure") {
                
                let rootComponent = try factory.makeComponent(json: json)
                window?.rootViewController = rootComponent?.viewController()
                window?.makeKeyAndVisible()
            }
            
        } catch {
            assert(false, "JSON could not be parsed")
        }
        
        return true
    }
}
