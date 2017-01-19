//
//  TileViewController.swift
//  MatrioskaExample
//
//  Created by Alex Manzella on 13/12/16.
//  Copyright © 2016 runtastic. All rights reserved.
//

import UIKit
import Matrioska

struct TileConfig: ExpressibleByComponentMeta {
    let text: String?
    let color: UIColor?
    
    init?(meta: ComponentMeta) {
        text = meta["text"] as? String
        
        let hexColor = meta["color"] as? String
        let color = UIColor(hexString: hexColor ?? "")
        self.color = color
    }
    
    init(text: String?, color: UIColor) {
        self.text = text
        self.color = color
    }
}

class TileViewController: UIViewController {

    let label = UILabel()
    let config: TileConfig
    
    required init?(meta: ComponentMeta?) {
        guard let meta = meta as? TileConfig else {
            return nil
        }
        config = meta
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = config.color
        view.addSubview(label)
        
        label.text = config.text
        label.font = UIFont.systemFont(ofSize: 25)
        label.textAlignment = .center
        label.snp.makeConstraints { (make) in
            make.edges.equalTo(view).inset(20)
            make.width.height.equalTo(100) // remove to just use the intrinsicContentSize
        }
    }
}
