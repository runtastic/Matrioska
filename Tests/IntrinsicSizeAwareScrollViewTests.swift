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
        
        let size = CGSize(width: 300, height: 200)
        
        describe("IntrinsicSizeAwareScrollView") {
            it("should have an intrinsicContentSize equal to its contentSize") {
                let scrollView = IntrinsicSizeAwareScrollView()
                scrollView.contentSize = size
                expect(scrollView.intrinsicContentSize) == size
            }
            
            it("should adapt its intrinsicContentSize when the contentSize changes") {
                let vc = UIViewController()
                let scrollView = IntrinsicSizeAwareScrollView()
                vc.view.addSubview(scrollView)
                vc.view.backgroundColor = .yellow
                
                scrollView.snp.makeConstraints { (make) in
                    make.leading.top.equalTo(vc.view)
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
                expect(scrollView.intrinsicContentSize) == size
            }
            
            context("when instantiated by Interface Builder") {
                it("should adapt its intrinsicContentSize when the contentSize changes") {
                    let bundle = Bundle(for: IntrinsicSizeAwareScrollViewTests.self)
                    // This need has almost the same setup as the previous test.
                    // However it contains some palceholder constraints, removed at build time,
                    // to avoid IB warnings.
                    let nib = UINib(nibName: "IntrinsicSizeAwareScrollViewTest",
                                     bundle: bundle)
                    let view = nib.instantiate(withOwner: nil, options: nil).first as? UIView
                    expect(view).to(haveValidSnapshot())
                    
                    let scrollView = view?.subviews.first as? UIScrollView
                    expect(scrollView?.intrinsicContentSize) == size
                }
            }
        }
    }
}
