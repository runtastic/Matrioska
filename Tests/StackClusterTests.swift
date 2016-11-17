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
                labelComponent(title: "third\ntwo lines", color: .orange),
                ]
            
            it("should display its child and respect their intrinsic contentSize") {
                let vc = stack(with: children)
                expect(vc).to(haveValidSnapshot())
            }
            
            it("should not display childs that don't have a view") {
                let children = [
                    labelComponent(title: "first", color: .red),
                    Component.view(builder: { _ in nil }, meta: nil),
                    labelComponent(title: "second", color: .orange),
                    Component.view(builder: { _ in nil }, meta: nil),
                    ]
                let vc = stack(with: children)
                expect(vc).to(haveValidSnapshot())
                expect(vc?.stackView.arrangedSubviews).to(haveCount(2))
            }
            
            context("when it doesn't have a valid configuration") {
                it("should use the default configuration") {
                    let children = [
                        labelComponent(title: "first", color: .yellow),
                        labelComponent(title: "second", color: .green),
                        ]
                    let vc = stack(with: children, meta: Meta(["foo": "bar"]))
                    expect(vc).to(haveValidSnapshot())
                    let defaultConfig = ClusterLayout.StackConfig()
                    expect(vc?.title).to(beNil())
                    expect(defaultConfig.name).to(beNil())
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
                
                it("should respect the name config") {
                    let config = ClusterLayout.StackConfig(name: "Wow")
                    let vc = stack(with: [], meta: config)
                    expect(vc?.title) == "Wow"
                }
                
                it("should respect the preserveParentWidth config") {
                    let config = ClusterLayout.StackConfig(preserveParentWidth: true)
                    let vc = stack(with: children, meta: config)
                    expect(vc).to(haveValidSnapshot())
                }
                
                it("should load config from a dictionary") {
                    let config: [String: Any] = [
                        "name": "Foo",
                        "spacing": 150.0,
                        "axis": UILayoutConstraintAxis.vertical.rawValue,
                        "preserveParentWidth": true,
                    ]
                    let vc = stack(with: children, meta: Meta(config))
                    expect(vc?.title) == "Foo"
                    expect(vc).to(haveValidSnapshot())
                    expect(vc?.stackView.spacing) == 150
                    expect(vc?.stackView.axis) == .vertical
                }
            }
            
            context("when the content overflows") {
                let size = CGSize(width: 300, height: 500)
                let children = [
                    labelComponent(title: "1", color: .red, labelSize: size),
                    labelComponent(title: "2", color: .red, labelSize: size),
                    labelComponent(title: "3", color: .red, labelSize: size),
                    labelComponent(title: "4", color: .red, labelSize: size),
                    ]

                it("should be able to scroll horizontally") {
                    let meta = ClusterLayout.StackConfig(axis: .horizontal)
                    let vc = stack(with: children, meta: meta)
                    let scrollView = vc?.stackView.superview as? UIScrollView

                    expect(vc).to(haveValidSnapshot())
                    expect(scrollView).to(scroll(.horizontal))
                    expect(scrollView).toNot(scroll(.vertical))
                }
                
                it("should be able to scroll vertically") {
                    let vc = stack(with: children)
                    let scrollView = vc?.stackView.superview as? UIScrollView

                    expect(vc).to(haveValidSnapshot())
                    expect(scrollView).to(scroll(.vertical))
                    expect(scrollView).toNot(scroll(.horizontal))
                }
            }
            
            context("when the content doesn't overflows") {
                it("should not be able to scroll") {
                    let children = [
                        labelComponent(title: "first", color: .red),
                        ]
                    let vc = stack(with: children)
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
                let fixedSizeChildren = [1, 2, 3, 4].map {
                    labelComponent(title: String($0), color: .red, labelSize: size)
                }

                let nest = [
                    ClusterLayout.stack(children: children, meta: meta),
                    ClusterLayout.stack(children: fixedSizeChildren, meta: horizontalMeta),
                    ClusterLayout.stack(children: children, meta: nil),
                ]
                
                let vc = stack(with: nest)
                expect(vc).to(haveValidSnapshot())
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
    let vc = stack.viewController() as? StackViewController
    vc?.view.backgroundColor = .white
    return vc
}

private func labelComponent(title: String?,
                            color: UIColor? = nil,
                            labelSize: CGSize? = nil) -> Component {
    
    let builder: Component.ViewBuilder = { meta in
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
    
    return Component.view(
        builder: builder,
        meta: title.map { Meta(["title": $0]) }
    )
}
