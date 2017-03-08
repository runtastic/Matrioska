//
//  MatrioskaCodeViewController.swift
//  MatrioskaExample
//
//  Created by Mathias Aichinger on 19/01/2017.
//  Copyright © 2017 runtastic. All rights reserved.
//

import UIKit
import Matrioska
import SnapKit

class MatrioskaCodeViewController: UIViewController {

    let rootComponent = ClusterLayout.stack(
        children: [
            tileComponent(meta: TileConfig(text: "One", color: .red)),
            tileComponent(meta: TileConfig(text: "Two", color: .green)),
            ClusterLayout.stack(
                children: [
                    tileComponent(meta: TileConfig(text: "A", color: .red)),
                    tileComponent(meta: TileConfig(text: "B", color: .green)),
                    tileComponent(meta: TileConfig(text: "C", color: .orange)),
                    tileComponent(meta: TileConfig(text: "D", color: .yellow))
                    ],
                meta: ClusterLayout.StackConfig(axis: .horizontal)
            ),
            tileComponent(meta: TileConfig(text: "Three", color: .orange)),
            tileComponent(meta: TileConfig(text: "Four", color: .yellow))
            ],
        meta: ClusterLayout.StackConfig(title: "Test",
                                        spacing: CGFloat(10.0),
                                        axis: .vertical,
                                        preserveParentWidth: true,
                                        backgroundColor: .blue)
    )
    
    required init?(meta: ComponentMeta?) {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red
        
        guard let rootViewController = rootComponent.viewController(), let rootView = rootViewController.view else {
            return
        }
        
        addChildViewController(rootViewController)
        view.addSubview(rootView)
        rootViewController.didMove(toParentViewController: self)
        rootView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view).inset(0)
        }
    }
}

private func tileComponent(meta: TileConfig) -> Component {
    return Component.single(viewBuilder: TileViewController.init(meta:), meta: meta)
}
