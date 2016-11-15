//
//  IntrinsicSizeAwareScrollViewTests.swift
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
import SnapKit
@testable import Matrioska

class IntrinsicSizeAwareScrollViewTests: QuickSpec {
    
    override func spec() {
        describe("IntrinsicSizeAwareScrollView") {
            it("should have an intrinsicContentSize equal to its contentSize") {
                let scrollView = IntrinsicSizeAwareScrollView()
                scrollView.contentSize = CGSize(width: 300, height: 200)
                expect(scrollView.intrinsicContentSize) == CGSize(width: 300, height: 200)
            }
            
            it("should adapt its intrinsicContentSize when the contentSize changes") {
                let vc = UIViewController()
                let scrollView = IntrinsicSizeAwareScrollView()
                vc.view.addSubview(scrollView)
                vc.view.backgroundColor = .yellow
                
                scrollView.snp.makeConstraints { (make) in
                    make.leading.top.trailing.equalTo(vc.view)
                }
                
                let view = UIView()
                view.backgroundColor = .purple
                scrollView.addSubview(view)
                view.snp.makeConstraints { (make) in
                    make.width.equalTo(300)
                    make.height.equalTo(200)
                    make.leading.top.equalTo(scrollView)
                    make.trailing.bottom.lessThanOrEqualTo(scrollView)
                }
                
                expect(vc).to(haveValidSnapshot())
                expect(scrollView.intrinsicContentSize) == CGSize(width: 300, height: 200)
            }
            
            it("should stop observing contentSize changes when it is deallocated") {
                var removed: Bool? = nil
                
                let fakeObserverManager = FakeObserverManager(observerRemovedCallback: {
                    removed = true
                })
                
                do {
                    let _ = IntrinsicSizeAwareScrollView(observerManager: fakeObserverManager)
                }
                
                expect(removed).to(beTrue())
            }
        }
    }
}

final class FakeObserverManager: ObserverManager {
    
    private let observerRemovedCallback: (Void) -> Void
    
    init(observerRemovedCallback: @escaping (Void) -> Void) {
        self.observerRemovedCallback = observerRemovedCallback
    }

    func addObserver(_ observer: NSObject,
                     to receiver: NSObject,
                     forKeyPath keyPath: String,
                     options: NSKeyValueObservingOptions,
                     context: UnsafeMutableRawPointer?) {
        
    }
    
    func removeObserver(_ observer: NSObject, from receiver: NSObject, forKeyPath keyPath: String) {
        observerRemovedCallback()
    }
}
