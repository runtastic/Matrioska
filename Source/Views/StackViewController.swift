//
//  StackViewController.swift
//  Matrioska
//
//  Created by Alex Manzella on 16/11/16.
//  Copyright © 2016 runtastic. All rights reserved.
//

import UIKit
import SnapKit

/// An enum that describes the relative position of an element. The enum should work horizontally as well as vertically.
/// Orientation depending meaning: beginning - top/left, end - bottom/right
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
        addChildViewController(childViewController)
        stackView.addArrangedSubview(childViewController.view)
        childViewController.didMove(toParentViewController: self)
    }
    
    /// A method to access the scrollView from outside and scroll to a given target ViewController.
    /// If no relativePosition parameter is provided, it will try to center the target.
    ///
    /// - Parameters:
    ///   - targetViewController: The ViewController which should scroll into focus
    ///   - position: An optional parameter to specify the alignement of the target. Depending of
    ///     the stackViews' orientation position values have different meaning:
    ///     beginning - top/left, end - bottom/right
    public func scroll(to targetViewController: UIViewController,
                       at position: RelativePosition = .center,
                       animated: Bool = false) {
        
        guard childViewControllers.contains(targetViewController) else {
            return
        }
        
        var targetOffset = CGPoint.zero
        let targetFrame = targetViewController.view.frame
        
        if stackView.axis == .vertical {
            // keep current horizontal offset
            targetOffset.x = scrollView.contentOffset.x
            let topOffset = targetFrame.origin.y - scrollView.contentInset.top
            let bottomOffset = targetFrame.maxY - scrollView.bounds.height
            let maxOffset = scrollView.contentSize.height - scrollView.bounds.height
            
            switch position {
            case .beginning:
                targetOffset.y = topOffset
            case .center:
                targetOffset.y = topOffset - (topOffset - bottomOffset) / 2
            case .end:
                targetOffset.y = bottomOffset
            }

            targetOffset.y = min(maxOffset, max(scrollView.contentInset.top, targetOffset.y))
        } else {
            // keep current vertical offset
            targetOffset.y = scrollView.contentOffset.y
            let leftOffset = targetFrame.origin.x - scrollView.contentInset.left
            let rightOffset = targetFrame.maxX - scrollView.bounds.width
            let maxOffset = scrollView.contentSize.width - scrollView.bounds.width
            switch position {
            case .beginning:
                targetOffset.x = leftOffset
            case .center:
                targetOffset.x = leftOffset - (leftOffset - rightOffset) / 2
            case .end:
                targetOffset.x = rightOffset
            }

            targetOffset.x = min(maxOffset, max(scrollView.contentInset.left, targetOffset.x))
        }

        scrollView.setContentOffset(targetOffset, animated: animated)
    }
}
