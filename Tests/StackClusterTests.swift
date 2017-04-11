//
//  StackClusterTests.swift
//  Matrioska
//
//  Created by Alex Manzella on 16/11/16.
//  Copyright © 2016 runtastic. All rights reserved.
//

import XCTest
import Quick
import Nimble
import Nimble_Snapshots
import FBSnapshotTestCase
@testable import Matrioska

class StackClusterTests: QuickSpec {
    
    override func spec() {
        
        describe("Stack component") {
            
            let children = [
                labelComponent(title: "first", color: .red),
                labelComponent(title: "second", color: .blue),
                labelComponent(title: "third\ntwo lines", color: .orange)
            ]
            
            it("should display its child and respect their intrinsic contentSize") {
                let vc = stack(with: children)
                expect(vc).to(haveValidSnapshot())
            }
            
            it("should not display childs that don't have a view") {
                let children = [
                    labelComponent(title: "first", color: .red),
                    Component.single(viewBuilder: { _ in nil }, meta: nil),
                    labelComponent(title: "second", color: .orange),
                    Component.single(viewBuilder: { _ in nil }, meta: nil)
                ]
                let vc = stack(with: children)
                expect(vc).to(haveValidSnapshot())
                expect(vc?.stackView.arrangedSubviews).to(haveCount(2))
            }
            
            context("when it doesn't have a valid configuration") {
                it("should use the default configuration") {
                    let children = [
                        labelComponent(title: "first", color: .yellow),
                        labelComponent(title: "second", color: .green)
                    ]
                    let vc = stack(with: children, meta: ["foo": "bar"])
                    expect(vc).to(haveValidSnapshot())
                    let defaultConfig = ClusterLayout.StackConfig()
                    expect(vc?.title).to(beNil())
                    expect(defaultConfig.title).to(beNil())
                    expect(vc?.stackView.spacing) == defaultConfig.spacing
                    expect(vc?.stackView.axis) == defaultConfig.axis
                }
            }
            
            context("when it has a valid configuration") {
                it("should respect the spacing config") {
                    let config = ClusterLayout.StackConfig(spacing: 150)
                    let vc = stack(with: children, meta: config)
                    expect(vc).to(haveValidSnapshot())
                }
                
                it("should respect the axis config") {
                    let config = ClusterLayout.StackConfig(axis: .horizontal)
                    let vc = stack(with: children, meta: config)
                    expect(vc).to(haveValidSnapshot())
                }
                
                it("should respect the title config") {
                    let config = ClusterLayout.StackConfig(title: "Wow")
                    let vc = stack(with: [], meta: config)
                    expect(vc?.title) == "Wow"
                }
                
                it("should respect the preserveParentWidth config") {
                    let config = ClusterLayout.StackConfig(preserveParentWidth: true)
                    let vc = stack(with: children, meta: config)
                    expect(vc).to(haveValidSnapshot())
                }
                
                it("should respect the backgroundColor config") {
                    let config = ClusterLayout.StackConfig(backgroundColor: UIColor.lightGray)
                    let vc = stack(with: children, meta: config)
                    expect(vc).to(haveValidSnapshot())
                }
                
                it("should load config from a dictionary") {
                    let config: [String: Any] = [
                        "title": "Foo",
                        "spacing": 150.0,
                        "orientation": "vertical",
                        "preserve_parent_width": true,
                        "background_color": "0xEEEEEE"
                    ]
                    
                    let vc = stack(with: children, meta: config)
                    expect(vc?.title) == "Foo"
                    expect(vc).to(haveValidSnapshot())
                    expect(vc?.stackView.spacing) == 150
                    expect(vc?.stackView.axis) == .vertical
                }
                
                it("should load horizontal config from a dictionary") {
                    let horizontalChildren = [
                        labelComponent(title: "1", color: .red),
                        labelComponent(title: "2", color: .blue),
                        labelComponent(title: "3", color: .orange)
                    ]
                    let config: [String: Any] = [
                        "title": "Foo",
                        "spacing": 50.0,
                        "orientation": "horizontal",
                        "preserve_parent_width": true,
                        "background_color": "0xEEEEEE"
                    ]
                    
                    let vc = stack(with: horizontalChildren, meta: config)
                    expect(vc?.title) == "Foo"
                    expect(vc).to(haveValidSnapshot())
                    expect(vc?.stackView.spacing) == 50
                    expect(vc?.stackView.axis) == .horizontal
                }
            }
            
            context("when the content overflows") {
                let size = CGSize(width: 300, height: 500)
                let children = [
                    labelComponent(title: "1", color: .red, labelSize: size),
                    labelComponent(title: "2", color: .red, labelSize: size),
                    labelComponent(title: "3", color: .red, labelSize: size),
                    labelComponent(title: "4", color: .red, labelSize: size)
                ]
                
                it("should be able to scroll horizontally") {
                    let meta = ClusterLayout.StackConfig(axis: .horizontal)
                    let vc = stack(with: children, meta: meta)
                    vc?.loadViewIfNeeded()
                    vc?.view.layoutIfNeeded()
                    let scrollView = vc?.stackView.superview as? UIScrollView
                    
                    expect(vc).to(haveValidSnapshot())
                    expect(scrollView).to(scroll(.horizontal))
                    expect(scrollView).toNot(scroll(.vertical))
                }
                
                it("should be able to scroll vertically") {
                    let vc = stack(with: children)
                    vc?.loadViewIfNeeded()
                    vc?.view.layoutIfNeeded()
                    let scrollView = vc?.stackView.superview as? UIScrollView
                    
                    expect(vc).to(haveValidSnapshot())
                    expect(scrollView).to(scroll(.vertical))
                    expect(scrollView).toNot(scroll(.horizontal))
                }
                
                context("when a horizontal stack is contained in a vertical stack") {
                    
                    let nestedStack: () -> StackViewController? = {
                        let horizontal = ClusterLayout.StackConfig(axis: .horizontal)
                        let vertical = ClusterLayout.StackConfig(axis: .vertical)
                        
                        return stack(
                            with: [ClusterLayout.stack(children: children, meta: horizontal)],
                            meta: vertical
                        )
                    }
                    
                    it("should not cause the parent stack to overflow horizontally") {
                        let vc = nestedStack()
                        vc?.loadViewIfNeeded()
                        
                        let scrollView = vc?.stackView.superview as? UIScrollView
                        
                        expect(vc).to(haveValidSnapshot())
                        expect(scrollView).toNot(scroll(.horizontal))
                    }
                    
                    it("should be able to scroll horizontally") {
                        let vc = nestedStack()
                        vc?.loadViewIfNeeded()
                        vc?.view.layoutIfNeeded()
                        let horizontalStack = vc?.childViewControllers.first as? StackViewController
                        let scrollView2 = horizontalStack?.stackView.superview as? UIScrollView
                        
                        expect(vc).to(haveValidSnapshot())
                        expect(scrollView2).to(scroll(.horizontal))
                    }
                }
            }
            
            context("when scrolling horizontally to the leftmost item, it") {
                let size = CGSize(width: 200, height: 300)
                let children = [
                    labelComponent(title: "1", color: .purple, labelSize: size),
                    labelComponent(title: "2", color: .red, labelSize: size),
                    labelComponent(title: "3", color: .yellow, labelSize: size),
                    labelComponent(title: "4", color: .green, labelSize: size),
                    labelComponent(title: "5", color: .blue, labelSize: size)
                ]
                
                let meta = ClusterLayout.StackConfig(axis: .horizontal)
                let vc = stack(with: children, meta: meta)
                vc?.loadViewIfNeeded()
                vc?.view.layoutIfNeeded()
                
                let purpleLeftmostTargetVC = vc?.childViewControllers[0]
                
                it("should get left aligned (although center requested)") {
                    vc?.scroll(to: purpleLeftmostTargetVC!, at: .center, animated: false)
                    expect(vc).to(haveValidSnapshot())
                }
                
                it("should get left aligned (although begin requested)") {
                    vc?.scroll(to: purpleLeftmostTargetVC!, at: .begin, animated: false)
                    expect(vc).to(haveValidSnapshot())
                }
                
                it("should get left aligned") {
                    vc?.scroll(to: purpleLeftmostTargetVC!, at: .end, animated: false)
                    expect(vc).to(haveValidSnapshot())
                }
            }
            
            context("when scrolling horizontally to a target, it") {
                let size = CGSize(width: 200, height: 300)
                let children = [
                    labelComponent(title: "1", color: .purple, labelSize: size),
                    labelComponent(title: "2", color: .red, labelSize: size),
                    labelComponent(title: "3", color: .yellow, labelSize: size),
                    labelComponent(title: "4", color: .green, labelSize: size),
                    labelComponent(title: "5", color: .blue, labelSize: size)
                ]
                
                let meta = ClusterLayout.StackConfig(axis: .horizontal)
                let vc = stack(with: children, meta: meta)
                vc?.loadViewIfNeeded()
                vc?.view.layoutIfNeeded()
                
                let yellowCenteredTargetVC = vc?.childViewControllers[2]

                it("should get centered (center requested)") {
                    vc?.scroll(to: yellowCenteredTargetVC!, at: .center, animated: false)
                    expect(vc).to(haveValidSnapshot())
                }
                
                it("should get left aligned (begin requested)") {
                    vc?.scroll(to: yellowCenteredTargetVC!, at: .begin, animated: false)
                    expect(vc).to(haveValidSnapshot())
                }
                
                it("should get right aligned (end requested)") {
                    vc?.scroll(to: yellowCenteredTargetVC!, at: .end, animated: false)
                    expect(vc).to(haveValidSnapshot())
                }
            }
            
            context("when scrolling horizontally to the rightmost item, it") {
                let size = CGSize(width: 200, height: 300)
                let children = [
                    labelComponent(title: "1", color: .purple, labelSize: size),
                    labelComponent(title: "2", color: .red, labelSize: size),
                    labelComponent(title: "3", color: .yellow, labelSize: size),
                    labelComponent(title: "4", color: .green, labelSize: size),
                    labelComponent(title: "5", color: .blue, labelSize: size)
                ]
                
                let meta = ClusterLayout.StackConfig(axis: .horizontal)
                let vc = stack(with: children, meta: meta)
                vc?.loadViewIfNeeded()
                vc?.view.layoutIfNeeded()
                
                let blueRightmostTargetVC = vc?.childViewControllers[4]
                
                it("should get right aligned (although center requested)") {
                    vc?.scroll(to: blueRightmostTargetVC!, at: .center, animated: false)
                    expect(vc).to(haveValidSnapshot())
                }
                
                it("should get right aligned (although begin requested)") {
                    vc?.scroll(to: blueRightmostTargetVC!, at: .begin, animated: false)
                    expect(vc).to(haveValidSnapshot())
                }
                
                it("should get right aligned (end requested)") {
                    vc?.scroll(to: blueRightmostTargetVC!, at: .end, animated: false)
                    expect(vc).to(haveValidSnapshot())
                }
            }
            
            context("when scrolling vertically to the topmost item, it") {
                let size = CGSize(width: 200, height: 300)
                let children = [
                    labelComponent(title: "1", color: .purple, labelSize: size),
                    labelComponent(title: "2", color: .red, labelSize: size),
                    labelComponent(title: "3", color: .yellow, labelSize: size),
                    labelComponent(title: "4", color: .green, labelSize: size),
                    labelComponent(title: "5", color: .blue, labelSize: size)
                ]
                
                let meta = ClusterLayout.StackConfig(axis: .vertical)
                let vc = stack(with: children, meta: meta)
                vc?.loadViewIfNeeded()
                vc?.view.layoutIfNeeded()
                
                let purpleTopmostTargetVC = vc?.childViewControllers[0]
                
                it("should get top aligned (although center requested)") {
                    vc?.scroll(to: purpleTopmostTargetVC!, at: .center, animated: false)
                    expect(vc).to(haveValidSnapshot())
                }
                
                it("should get top aligned (begin requested)") {
                    vc?.scroll(to: purpleTopmostTargetVC!, at: .begin, animated: false)
                    expect(vc).to(haveValidSnapshot())
                }
                
                it("should get top aligned (although end requested)") {
                    vc?.scroll(to: purpleTopmostTargetVC!, at: .end, animated: false)
                    expect(vc).to(haveValidSnapshot())
                }
            }
            
            context("when scrolling vertically to a target, it") {
                let size = CGSize(width: 200, height: 300)
                let children = [
                    labelComponent(title: "1", color: .purple, labelSize: size),
                    labelComponent(title: "2", color: .red, labelSize: size),
                    labelComponent(title: "3", color: .yellow, labelSize: size),
                    labelComponent(title: "4", color: .green, labelSize: size),
                    labelComponent(title: "5", color: .blue, labelSize: size)
                ]
                
                let meta = ClusterLayout.StackConfig(axis: .vertical)
                let vc = stack(with: children, meta: meta)
                vc?.loadViewIfNeeded()
                vc?.view.layoutIfNeeded()
                
                let yellowCenteredTargetVC = vc?.childViewControllers[2]
                
                it("should get centered (center requested)") {
                    vc?.scroll(to: yellowCenteredTargetVC!, at: .center, animated: false)
                    expect(vc).to(haveValidSnapshot())
                }
                
                it("should get top aligned (begin requested)") {
                    vc?.scroll(to: yellowCenteredTargetVC!, at: .begin, animated: false)
                    expect(vc).to(haveValidSnapshot())
                }
                
                it("should get bottom aligned (end requested)") {
                    vc?.scroll(to: yellowCenteredTargetVC!, at: .end, animated: false)
                    expect(vc).to(haveValidSnapshot())
                }
            }
            
            context("when scrolling vertically to the bottommost item, it") {
                let size = CGSize(width: 200, height: 300)
                let children = [
                    labelComponent(title: "1", color: .purple, labelSize: size),
                    labelComponent(title: "2", color: .red, labelSize: size),
                    labelComponent(title: "3", color: .yellow, labelSize: size),
                    labelComponent(title: "4", color: .green, labelSize: size),
                    labelComponent(title: "5", color: .blue, labelSize: size)
                ]
                
                let meta = ClusterLayout.StackConfig(axis: .vertical)
                let vc = stack(with: children, meta: meta)
                vc?.loadViewIfNeeded()
                vc?.view.layoutIfNeeded()
                
                let blueBottommostTargetVC = vc?.childViewControllers[4]
                
                it("should get bottom aligned (although center requested)") {
                    vc?.scroll(to: blueBottommostTargetVC!, at: .center, animated: false)
                    expect(vc).to(haveValidSnapshot())
                }
                
                it("should get bottom aligned (although begin requested)") {
                    vc?.scroll(to: blueBottommostTargetVC!, at: .begin, animated: false)
                    expect(vc).to(haveValidSnapshot())
                }
                
                it("should get bottom aligned (end requested)") {
                    vc?.scroll(to: blueBottommostTargetVC!, at: .end, animated: false)
                    expect(vc).to(haveValidSnapshot())
                }
            }
            
            context("when scrolling horizontally in a vertical nested stack, the target") {
                let meta = ClusterLayout.StackConfig(preserveParentWidth: true)
                let horizontalChildMeta = ClusterLayout.StackConfig(axis: .horizontal)
                let size = CGSize(width: 100, height: 100)
                let fixedSizeChildren = (1...4).map {
                    labelComponent(title: String($0), color: .brown, labelSize: size)
                }
                let sizeNested = CGSize(width: 150, height: 50)
                let children = [
                    labelComponent(title: "1", color: .purple, labelSize: sizeNested),
                    labelComponent(title: "2", color: .red, labelSize: sizeNested),
                    labelComponent(title: "3", color: .yellow, labelSize: sizeNested),
                    labelComponent(title: "4", color: .green, labelSize: sizeNested),
                    labelComponent(title: "5", color: .blue, labelSize: sizeNested)
                ]
                
                let nest = [
                    ClusterLayout.stack(children: fixedSizeChildren, meta: meta),
                    ClusterLayout.stack(children: children, meta: horizontalChildMeta),
                    ClusterLayout.stack(children: fixedSizeChildren, meta: meta)
                ]
                
                let vc = stack(with: nest)
                vc?.loadViewIfNeeded()
                vc?.view.layoutIfNeeded()

                let childStack = vc?.childViewControllers[1] as? StackViewController
                let targetVC = childStack?.childViewControllers[2]
                
                it("should get centered") {
                    childStack?.scroll(to: targetVC!, at: .center, animated: false)
                    expect(vc).to(haveValidSnapshot())
                }
                
                it("should get left aligned") {
                    childStack?.scroll(to: targetVC!, at: .begin, animated: false)
                    expect(vc).to(haveValidSnapshot())
                }
                
                it("should get right aligned") {
                    childStack?.scroll(to: targetVC!, at: .end, animated: false)
                    expect(vc).to(haveValidSnapshot())
                }
            }
            
            context("when scrolling vertically in a horizontal nested stack, the target") {
                let meta = ClusterLayout.StackConfig(axis: .horizontal)
                let verticalChildMeta = ClusterLayout.StackConfig(axis: .vertical)
                let size = CGSize(width: 40, height: 250)
                let fixedSizeChildren = (1...3).map {
                    labelComponent(title: String($0), color: .brown, labelSize: size)
                }
                let sizeNested = CGSize(width: 50, height: 150)
                let children = [
                    labelComponent(title: "1", color: .purple, labelSize: sizeNested),
                    labelComponent(title: "2", color: .red, labelSize: sizeNested),
                    labelComponent(title: "3", color: .yellow, labelSize: sizeNested),
                    labelComponent(title: "4", color: .green, labelSize: sizeNested),
                    labelComponent(title: "5", color: .blue, labelSize: sizeNested)
                ]
                
                let nest = [
                    ClusterLayout.stack(children: fixedSizeChildren, meta: meta),
                    ClusterLayout.stack(children: children, meta: verticalChildMeta),
                    ClusterLayout.stack(children: fixedSizeChildren, meta: meta)
                ]
                
                let vc = stack(with: nest, meta: meta)
                vc?.loadViewIfNeeded()
                vc?.view.layoutIfNeeded()
                
                let childStack = vc?.childViewControllers[1] as? StackViewController
                let targetVC = childStack?.childViewControllers[2]

                it("should get centered") {
                    childStack?.scroll(to: targetVC!, at: .center, animated: false)
                    expect(vc).to(haveValidSnapshot())
                }
                
                it("should get on top") {
                    childStack?.scroll(to: targetVC!, at: .begin, animated: false)
                    expect(vc).to(haveValidSnapshot())
                }
                
                it("should get on the bottom") {
                    childStack?.scroll(to: targetVC!, at: .end, animated: false)
                    expect(vc).to(haveValidSnapshot())
                }
            }
            
            context("when the content doesn't overflows") {
                it("should not be able to scroll") {
                    let children = [labelComponent(title: "first", color: .red)]
                    let vc = stack(with: children)
                    vc?.view.layoutIfNeeded()
                    expect(vc).to(haveValidSnapshot())
                    let scrollView = vc?.stackView.superview as? UIScrollView
                    expect(scrollView).toNot(scroll(.vertical))
                    expect(scrollView).toNot(scroll(.horizontal))
                }
            }
            
            it("should be nestable") {
                let meta = ClusterLayout.StackConfig(preserveParentWidth: true)
                let horizontalMeta = ClusterLayout.StackConfig(axis: .horizontal)
                let size = CGSize(width: 100, height: 100)
                let fixedSizeChildren = (1...4).map {
                    labelComponent(title: String($0), color: .red, labelSize: size)
                }
                
                let nest = [
                    ClusterLayout.stack(children: children, meta: meta),
                    ClusterLayout.stack(children: fixedSizeChildren, meta: horizontalMeta),
                    ClusterLayout.stack(children: children, meta: nil)
                ]
                
                let vc = stack(with: nest)
                expect(vc).to(haveValidSnapshot())
            }
            
            context("when presenting children view controllers") {
                it("should call viewWillAppear before appearing") {
                    var done: Bool? = nil
                    let vc = AppearanceSpyViewController()
                    vc.willAppear = { (view) in
                        done = true
                    }
                    
                    let stack = stackViewController(with: vc)
                    stack?.beginAppearanceTransition(true, animated: false)
                    expect(done).to(beTrue())
                    stack?.endAppearanceTransition()
                }
                
                it("should call viewDidAppear after appearing") {
                    var done: Bool? = nil
                    let vc = AppearanceSpyViewController()
                    vc.didAppear = { (view) in
                        done = true
                    }
                    
                    let stack = stackViewController(with: vc)
                    stack?.beginAppearanceTransition(true, animated: false)
                    stack?.endAppearanceTransition()
                    expect(done).to(beTrue())
                }
                
                it("should call viewWillDisappear before disappearing") {
                    var done: Bool? = nil
                    let vc = AppearanceSpyViewController()
                    vc.willDisappear = { (view) in
                        done = true
                    }
                    
                    let stack = stackViewController(with: vc)
                    stack?.beginAppearanceTransition(true, animated: false)
                    stack?.endAppearanceTransition()
                    
                    stack?.beginAppearanceTransition(false, animated: false)
                    expect(done).to(beTrue())
                    stack?.endAppearanceTransition()
                }
                
                it("should call viewDidDisappear after disappearing") {
                    var done: Bool? = nil
                    let vc = AppearanceSpyViewController()
                    vc.didDisappear = { (view) in
                        done = true
                    }
                    
                    let stack = stackViewController(with: vc)
                    stack?.beginAppearanceTransition(true, animated: false)
                    stack?.endAppearanceTransition()
                    
                    stack?.beginAppearanceTransition(false, animated: false)
                    stack?.endAppearanceTransition()
                    expect(done).to(beTrue())
                }
            }
        }
        
        describe("StackViewController") {
            it("should throw an assertion when initialized with interface builder") {
                let faultyInit = { _ = StackViewController(coder: NSCoder()) }
                expect(faultyInit()).to(throwAssertion())
            }
        }
    }
}

// MARK: Helpers

private func stack(with children: [Component], meta: ComponentMeta? = nil) -> StackViewController? {
    let stack = ClusterLayout.stack(children: children, meta: meta)
    return stack.viewController() as? StackViewController
}

func stackViewController(with child: UIViewController) -> UIViewController? {
    let component = Component.single(viewBuilder: { _ in child }, meta: nil)
    return ClusterLayout.stack(children: [component], meta: nil).viewController()
}

private func labelComponent(title: String?,
                            color: UIColor? = nil,
                            labelSize: CGSize? = nil) -> Component {
    
    let viewBuilder: Component.SingleViewBuilder = { meta in
        let vc = UIViewController()
        vc.view.backgroundColor = color
        let label = UILabel()
        label.text = meta?["title"] as? String
        label.numberOfLines = 0
        label.textAlignment = .center
        vc.view.addSubview(label)
        label.snp.makeConstraints { (make) in
            make.edges.equalTo(vc.view)
            if let size = labelSize {
                make.size.equalTo(size)
            }
        }
        return vc
    }
    
    return Component.single(
        viewBuilder: viewBuilder,
        meta: title.map { ["title": $0] }
    )
}
