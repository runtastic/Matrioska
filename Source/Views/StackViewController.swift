//
//  StackViewController.swift
//  Matrioska
//
//  Created by Alex Manzella on 16/11/16.
//  Copyright © 2016 runtastic. All rights reserved.
//

import UIKit
import SnapKit

/// A ViewController that contains a stackView
final class StackViewController: UIViewController {
    
    private let preserveParentWidth: Bool
    private let scrollView = IntrinsicSizeAwareScrollView()
    
    let stackView = UIStackView()
    
    typealias Configuration = ClusterLayout.StackConfig
    
    init(configuration: Configuration? = nil) {
        let configuration = configuration ?? Configuration()
        self.preserveParentWidth = configuration.preserveParentWidth
        
        super.init(nibName: nil, bundle: nil)

        title = configuration.title
        stackView.distribution = .equalSpacing
        stackView.axis = configuration.axis
        stackView.spacing = configuration.spacing
        
        if !preserveParentWidth {
            stackView.alignment = .leading
        }

        scrollView.backgroundColor = configuration.backgroundColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(scrollView)
        scrollView.alwaysBounceVertical = false
        scrollView.showsHorizontalScrollIndicator = false
        
        scrollView.snp.makeConstraints { (make) in
            make.edges.equalTo(view)
        }
        
        scrollView.addSubview(stackView)
        
        stackView.snp.makeConstraints { (make) in
            make.edges.equalTo(scrollView)
            if preserveParentWidth {
                make.width.equalTo(view)
            } else if stackView.axis == .vertical {
                make.width.lessThanOrEqualTo(view)
            }
        }
    }
    
    func add(child childViewController: UIViewController) {
        addChild(childViewController)
        stackView.addArrangedSubview(childViewController.view)
        childViewController.didMove(toParent: self)
    }
}
