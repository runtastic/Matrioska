//
//  TabBarClusterTests.swift
//  Matrioska
//
//  Created by Alex Manzella on 15/11/16.
//  Copyright © 2016 runtastic. All rights reserved.
//

import XCTest
import Quick
import Nimble
import Nimble_Snapshots
import FBSnapshotTestCase
@testable import Matrioska

class TabBarClusterTests: QuickSpec {
    
    override func spec() {
        
        describe("Tab bar component") {
            
            let children: [Component] = [
                simpleComponent(meta: TabConfig(name: "test1"), color: .red),
                simpleComponent(meta: TabConfig(name: "test2"), color: .blue),
                simpleComponent(meta: TabConfig(name: "test3"), color: .orange),
                ]
            
            it("should display its children") {
                let children: [Component] = [
                    simpleComponent(meta: TabConfig(name: "test1"), color: .purple),
                ]
                let vc = ClusterLayout.tabBar(children: children, meta: nil).viewController()
                expectTabCount(vc) == 1
                expect(vc).to(haveValidSnapshot())
            }
            
            it("should configure the tabBar") {

                let vc = ClusterLayout.tabBar(children: children, meta: nil).viewController()
                expectTabCount(vc) == 3
                expect(vc).to(haveValidSnapshot())
            }
            
            context("when meta represents the selected index") {
                
                it("should consider it and select the proper tab") {
                    let vc = ClusterLayout.tabBar(children: children, meta: 1).viewController()
                    expectTabCount(vc) == 3
                    expect(vc).to(haveValidSnapshot())
                }
                
                it("should not consider it if the index is out of bouds") {
                    let vc = ClusterLayout.tabBar(children: children, meta: 3).viewController()
                    expectTabCount(vc) == 3
                    expect(vc).to(haveValidSnapshot())
                }
                
                it("should not be considered if is less than 0") {
                    let vc = ClusterLayout.tabBar(children: children, meta: -1).viewController()
                    expectTabCount(vc) == 3
                    expect(vc).to(haveValidSnapshot())
                }
            }
            
            context("when meta doesn't represents the selected index") {
                it("should not be considered") {
                    let vc = ClusterLayout.tabBar(children: children, meta: "blah").viewController()
                    expectTabCount(vc) == 3
                    expect(vc).to(haveValidSnapshot())
                }
            }
            
            it("should ignore children without view") {
                let children: [Component] = [
                    Component.view(builder: { _ in nil }, meta: TabConfig(name: "_")),
                    simpleComponent(meta: TabConfig(name: "test1"), color: .red),
                    ]
                let vc = ClusterLayout.tabBar(children: children, meta: nil).viewController()
                expectTabCount(vc) == 1
                expect(vc).to(haveValidSnapshot())
            }
            
            context("children config") {
                
                let validComponent = simpleComponent(meta: TabConfig(name: "foo"), color: .green)
                
                it("should ignore children without config") {
                    let children: [Component] = [
                        simpleComponent(meta: nil),
                        validComponent,
                        ]
                    let vc = ClusterLayout.tabBar(children: children, meta: nil).viewController()
                    expectTabCount(vc) == 1
                    expect(vc).to(haveValidSnapshot())
                }
                
                it("should use config defined as dictionaries") {
                    let bundle = Bundle(for: TabBarClusterTests.self)
                    let children: [Component] = [
                        simpleComponent(meta: ["name": "test", "iconName": "checkmark"]),
                        validComponent,
                        ]
                    let vc = ClusterLayout.tabBar(children: children,
                                                  meta: nil,
                                                  bundle: bundle).viewController()
                    expectTabCount(vc) == 2
                    expect(vc).to(haveValidSnapshot())
                }
                
                it("should not use config defined as dictionaries when missing the name") {
                    let children: [Component] = [
                        simpleComponent(meta: ["iconName": "_"]),
                        validComponent,
                        ]
                    let vc = ClusterLayout.tabBar(children: children, meta: nil).viewController()
                    expectTabCount(vc) == 1
                    expect(vc).to(haveValidSnapshot())
                }
                
                it("should not use config defined as dictionaries when missing the iconName") {
                    let children: [Component] = [
                        simpleComponent(meta: ["name": "_"]),
                        validComponent,
                        ]
                    let vc = ClusterLayout.tabBar(children: children, meta: nil).viewController()
                    expectTabCount(vc) == 1
                    expect(vc).to(haveValidSnapshot())
                }
            }
        }
    }
}

// MARK: Convenience

private func expectTabCount(_ viewController: UIViewController?,
                            file: FileString = #file,
                            line: UInt = #line) -> Expectation<Int> {
    let tabBarController = viewController as? UITabBarController
    return expect(tabBarController?.viewControllers?.count ?? -1, file: file, line: line)
}

private func simpleComponent(meta: Any?, color: UIColor? = nil) -> Component {
    let builder: Component.ViewBuilder = { meta in
        let vc = UIViewController()
        vc.view.backgroundColor = color
        return vc
    }
    
    return Component.view(builder: builder,
                          meta: meta)
}

private typealias TabConfig = ClusterLayout.TabConfig

private extension TabConfig {
    init(name: String) {
        self = TabConfig(name: name,
                         iconName: "checkmark",
                         bundle: Bundle(for: TabBarClusterTests.self))
    }
}
