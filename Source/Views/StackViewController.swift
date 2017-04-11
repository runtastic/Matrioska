//
//  StackViewController.swift
//  Matrioska
//
//  Created by Alex Manzella on 16/11/16.
//  Copyright © 2016 runtastic. All rights reserved.
//

import UIKit
import SnapKit

public enum RelativePosition {
    case beginning
    case center
    case end
}

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
    
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(scrollView)
        scrollView.alwaysBounceVertical = false
        scrollView.showsHorizontalScrollIndicator = false
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view)
        }
        
        scrollView.addSubview(stackView)
        
        stackView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView)
            if preserveParentWidth {
                make.width.equalTo(view)
            } else if stackView.axis == .vertical {
                make.width.lessThanOrEqualTo(view)
            }
        }
    }
    
    func add(child childViewController: UIViewController) {
        addChildViewController(childViewController)
        stackView.addArrangedSubview(childViewController.view)
        childViewController.didMove(toParentViewController: self)
    }
    
    /// A method to access the scrollView from outside and scroll to a given target ViewController. 
    /// If no relativePosition parameter is provided, it will try to center the target.
    ///
    /// - Parameters:
    ///   - target: The ViewController which should scroll into focus
    ///   - relativePosition: An optional parameter to specify the alignement of the target. Depending of
    ///     the stackViews' orientation some relativePosition values have different meaning: 
    ///     beginning - top/left, end - bottom/right
    public func scrollToViewController(target targetViewController: UIViewController,
                                       position relativePosition: RelativePosition = .center) {
        
        guard self.childViewControllers.contains(targetViewController) else {
            return
        }
        
        var targetOffset = CGPoint(x: 0, y: 0)
        let targetFrame = targetViewController.view.frame
        
        if stackView.axis == .vertical {
            targetOffset.x = -scrollView.contentInset.left
            let topOffset = targetFrame.origin.y - scrollView.contentInset.top
            let bottomOffset = targetFrame.origin.y + targetFrame.height - scrollView.bounds.height
            
            switch relativePosition {
            case .beginning:
                targetOffset.y = topOffset
                break
            case .center:
                targetOffset.y = topOffset - bottomOffset - (targetFrame.height / 2)
                break
            case .end:
                targetOffset.y = bottomOffset
                break
            }
        } else {
            targetOffset.y = -scrollView.contentInset.top
            let rightOffset = targetFrame.origin.x + targetFrame.width - scrollView.bounds.width
            
            switch relativePosition {
            case .beginning:
                targetOffset.x = targetFrame.origin.x - scrollView.contentInset.left
                break
            case .center:
                targetOffset.x = -(targetOffset.x - rightOffset - (targetFrame.width / 2))
                break
            case .end:
                targetOffset.x = rightOffset
                break
            }
        }
        
        scrollView.setContentOffset(targetOffset, animated: true)
    }
}
