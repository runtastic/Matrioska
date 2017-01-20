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
        
        typealias DictMeta = [String: String]
        
        describe("View component") {
            it("should build a viewController") {
                let component = Component.view(builder: { _ in UIViewController() }, meta: nil)
                expect(component.viewController()).toNot(beNil())
            }
            
            it("should pass metadata to the builder") {
                var value: ComponentMeta? = nil
                _ = Component.view(builder: { (meta) in
                    value = meta
                    return UIViewController()
                }, meta: ["foo": "bar"]).viewController()
                
                expect(value as? DictMeta) == ["foo": "bar"]
            }
            
            it("should have the correct metadata") {
                let component = Component.view(builder: { _ in UIViewController() },
                                               meta: ["foo": "bar"])
                
                expect(component.meta as? DictMeta) == ["foo": "bar"]
            }
        }
        
        describe("Wrapper component") {
            it("should build a viewController") {
                let component = Component.wrapper(builder: { _ in UIViewController() },
                                                  child: randComponent(),
                                                  meta: nil)
                expect(component.viewController()).toNot(beNil())
            }
            
            it("should pass the child to the builder") {
                var component: Component? = nil
                let builder: Component.WrapperBuilder = { (child, _) in
                    component = child
                    return UIViewController()
                }
                
                _ =  Component.wrapper(builder: builder,
                                       child: randComponent(),
                                       meta: nil).viewController()
                
                expect(component).toNot(beNil())
            }
            
            it("should pass metadata to the builder") {
                var value: ComponentMeta? = nil
                let builder: Component.WrapperBuilder = { (_, meta) in
                    value = meta
                    return UIViewController()
                }
                
                _ =  Component.wrapper(builder: builder,
                                       child: randComponent(),
                                       meta: ["foo": "bar"]).viewController()
                
                expect(value as? DictMeta) == ["foo": "bar"]
            }
            
            it("should have the correct metadata") {
                let component =  Component.wrapper(builder: { _ in UIViewController() },
                                       child: randComponent(),
                                       meta: ["foo": "bar"])
                
                expect(component.meta as? DictMeta) == ["foo": "bar"]
            }
        }
        
        describe("Cluster component") {
            it("should build a viewController") {
                let component = Component.cluster(builder: { _ in UIViewController() },
                                                  children: [randComponent()],
                                                  meta: nil)
                expect(component.viewController()).toNot(beNil())
            }
            
            it("should pass the children to the builder") {
                var components: [Component]? = nil
                let builder: Component.ClusterBuilder = { (children, _) in
                    components = children
                    return UIViewController()
                }
                
                _ =  Component.cluster(builder: builder,
                                       children: [randComponent()],
                                       meta: nil).viewController()
                
                expect(components).toNot(beNil())
            }
            
            it("should pass metadata to the builder") {
                var value: ComponentMeta? = nil
                let builder: Component.ClusterBuilder = { (_, meta) in
                    value = meta
                    return UIViewController()
                }
                
                _ =  Component.cluster(builder: builder,
                                       children: [randComponent()],
                                       meta: ["foo": "bar"]).viewController()
                
                expect(value as? DictMeta) == ["foo": "bar"]
            }
            
            it("should have the correct metadata") {
                let component =  Component.cluster(builder: { _ in UIViewController() },
                                                   children: [randComponent()],
                                                   meta: ["foo": "bar"])
                
                expect(component.meta as? DictMeta) == ["foo": "bar"]
            }
        }
        
        describe("Rule component") {
            it("builds his child view controller if it evaluates to true") {
                let cluster = Component.cluster(builder: { _ in UIViewController() },
                                                children: [randComponent()],
                                                meta: nil)
                let rule = Rule.not(rule: Rule.simple(evaluator: { false }))
                let component = Component.rule(rule: rule, component: cluster)
                expect(component.viewController()).toNot(beNil())
            }
            
            it("does not build his child view controller if it evaluates to false") {
                let cluster = Component.cluster(builder: { _ in UIViewController() },
                                                children: [randComponent()],
                                                meta: nil)
                let rule = Rule.and(left: Rule.simple(evaluator: { false }), right: Rule.simple(evaluator: { true }))
                let component = Component.rule(rule: rule, component: cluster)
                expect(component.viewController()).to(beNil())
            }
            
            it("passes the children to the child's builder if it evaluates to true") {
                let rule = Rule.or(left: Rule.simple(evaluator: { false }), right: Rule.simple(evaluator: { true }))
                var components: [Component]? = nil
                let builder: Component.ClusterBuilder = { (children, _) in
                    components = children
                    return UIViewController()
                }
                let cluster = Component.cluster(builder: builder,
                                                children: [randComponent()],
                                                meta: nil)
                
                _ = Component.rule(rule: rule, component: cluster).viewController()
                
                expect(components).toNot(beNil())
            }
            
            it("does not pass the children to the child's builder if it evaluates to false") {
                let rule = Rule.not(rule: Rule.simple(evaluator: { true }))
                var components: [Component]? = nil
                let builder: Component.ClusterBuilder = { (children, _) in
                    components = children
                    return UIViewController()
                }
                let cluster = Component.cluster(builder: builder,
                                                children: [randComponent()],
                                                meta: nil)
                
                _ = Component.rule(rule: rule, component: cluster).viewController()
                
                expect(components).to(beNil())
            }
            
            it("passes metadata to the child's builder if it evaluates to true") {
                let rule = Rule.not(rule: Rule.simple(evaluator: { false }))
                var value: ComponentMeta? = nil
                let builder: Component.ClusterBuilder = { (_, meta) in
                    value = meta
                    return UIViewController()
                }
                let cluster = Component.cluster(builder: builder,
                                                children: [randComponent()],
                                                meta: ["foo": "bar"])
                
                _ =  Component.rule(rule: rule, component: cluster).viewController()
                
                expect(value as? DictMeta) == ["foo": "bar"]
            }
            
            it("does not pass metadata to the child's builder if it evaluates to false") {
                let rule = Rule.simple(evaluator: { false })
                var value: ComponentMeta? = nil
                let builder: Component.ClusterBuilder = { (_, meta) in
                    value = meta
                    return UIViewController()
                }
                let cluster = Component.cluster(builder: builder,
                                                children: [randComponent()],
                                                meta: ["one": "two"])
                
                _ =  Component.rule(rule: rule, component: cluster).viewController()
                
                expect(value).to(beNil())
            }
            
            it("has the correct child's metadata regardless of evaluating to true/false") {
                let rule = Rule.simple(evaluator: { false })
                let cluster =  Component.cluster(builder: { _ in UIViewController() },
                                                   children: [randComponent()],
                                                   meta: ["foo": "bar"])
                let falseComponent = Component.rule(rule: rule, component: cluster)
                let trueComponent = Component.rule(rule: Rule.not(rule: rule), component: cluster)
                
                expect(falseComponent.meta as? DictMeta) == ["foo": "bar"]
                expect(trueComponent.meta as? DictMeta) == ["foo": "bar"]
            }
        }
    }
}

private func randComponent() -> Component {
    return  Component.view(builder: { _ in UIViewController() }, meta: nil)
}
