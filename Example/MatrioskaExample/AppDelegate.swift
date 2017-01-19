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
        
        let tabBarBuilder: JSONFactory.ClusterFactoryBuilder = { (children, meta) in
            ClusterLayout.tabBar(children: children, meta: meta)
        }
        
        let stackBuilder: JSONFactory.ClusterFactoryBuilder = { (children, meta) in
            ClusterLayout.stack(children: children, meta: meta)
        }
        
        let navigationBuilder: JSONFactory.WrapperFactoryBuilder = { (child, meta) in
            Component.wrapper(builder: { (child, meta) in
                guard let vc = child.viewController() else {
                    return nil
                }
                return UINavigationController(rootViewController: vc)
            }, child: child, meta: meta)
        }
        
        let tileBuilder: JSONFactory.ViewFactoryBuilder = { (meta) in
            Component.view(builder: { (meta) -> UIViewController? in
                    TileViewController.init(meta: TileConfig.materialize(meta))
                }, meta: meta)
        }
        
        let matrioskaCodeBuilder: JSONFactory.ViewFactoryBuilder = { (meta) in
            Component.view(builder: MatrioskaCodeViewController.init(meta:), meta: meta)
        }
        
        factory.register(with: "tabbar", factoryBuilder: tabBarBuilder)
        factory.register(with: "stack", factoryBuilder: stackBuilder)
        factory.register(with: "navigation", factoryBuilder: navigationBuilder)
        factory.register(with: "tile", factoryBuilder: tileBuilder)
        factory.register(with: "matrioska", factoryBuilder: matrioskaCodeBuilder)
        
        do {
            if let json = try JSONReader.jsonObject(from: "app_structure"),
                let structure = json["structure"] as? JSONObject {
                let rootComponent = try factory.component(from: structure)
                window?.rootViewController = rootComponent?.viewController()
                window?.makeKeyAndVisible()
            }
            
        } catch {
            assert(false, "JSON could not be parsed")
        }
        
        return true
    }
}
