//
//  ComponentTests.swift
//  MatrioskaTests
//
//  Created by Alex Manzella on 09/11/16.
//  Copyright © 2016 runtastic. All rights reserved.
//

import XCTest
import Quick
import Nimble
@testable import Matrioska

class ComponentTests: QuickSpec {
    override func spec() {
        
        describe("View component") {
            it("should build a child ViewController") {
                let component = Component.view(builder: { _ in UIViewController() }, meta: nil)
                expect(component.childViewController()).toNot(beNil())
            }
            
            it("should pass metadata to the builder") {
                var string: String? = nil
                _ = Component.view(builder: { (meta) in
                    string = meta as? String
                    return UIViewController()
                }, meta: "meta").childViewController()
                
                expect(string) == "meta"
            }
        }
        
        describe("Wrapper component") {
            it("should build a child ViewController") {
                let component = Component.wrapper(builder: { _ in UIViewController() },
                                                  child: randComponent(),
                                                  meta: nil)
                expect(component.childViewController()).toNot(beNil())
            }
            
            it("should pass the child to the builder") {
                var component: Component? = nil
                let builder: Component.WrapperBuilder = { (child, _) in
                    component = child
                    return UIViewController()
                }
                
                _ =  Component.wrapper(builder: builder,
                                       child: randComponent(),
                                       meta: nil).childViewController()
                expect(component).toNot(beNil())
            }
            
            it("should pass metadata to the builder") {
                var string: String? = nil
                let builder: Component.WrapperBuilder = { (_, meta) in
                    string = meta as? String
                    return UIViewController()
                }
                
                _ =  Component.wrapper(builder: builder,
                                       child: randComponent(),
                                       meta: "meta").childViewController()
                
                expect(string) == "meta"
            }
        }
        
        describe("Cluster component") {
            it("should build a child ViewController") {
                let component = Component.cluster(builder: { _ in UIViewController() },
                                                  children: [randComponent()],
                                                  meta: nil)
                expect(component.childViewController()).toNot(beNil())
            }
            
            it("should pass the children to the builder") {
                var components: [Component]? = nil
                let builder: Component.ClusterBuilder = { (children, _) in
                    components = children
                    return UIViewController()
                }
                
                _ =  Component.cluster(builder: builder,
                                       children: [randComponent()],
                                       meta: nil).childViewController()
                expect(components).toNot(beNil())
            }
            
            it("should pass metadata to the builder") {
                var string: String? = nil
                let builder: Component.ClusterBuilder = { (_, meta) in
                    string = meta as? String
                    return UIViewController()
                }
                
                _ =  Component.cluster(builder: builder,
                                       children: [randComponent()],
                                       meta: "meta").childViewController()
                
                expect(string) == "meta"
            }
        }
    }
}

private func randComponent() -> Component {
    return  Component.view(builder: { _ in UIViewController() }, meta: nil)
}
