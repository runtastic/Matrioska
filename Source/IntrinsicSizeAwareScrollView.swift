//
//  IntrinsicSizeAwareScrollView.swift
//  Matrioska
//
//  Created by Alex Manzella on 15/11/16.
//  Copyright © 2016 runtastic. All rights reserved.
//

import Foundation
import UIKit

/// A `UIScrollView` subclass that adapts its `intrinsicContentSize` to its `contentSize`
final class IntrinsicSizeAwareScrollView: UIScrollView {
    
    private let keyPath = NSStringFromSelector(#selector(getter: contentSize))
    private let observerManager: ObserverManager
    
    required init(frame: CGRect = .zero, observerManager: ObserverManager = KVOManager()) {
        self.observerManager = observerManager
        super.init(frame: frame)
        addContentSizeObserver()
    }

    required init?(coder aDecoder: NSCoder) {
        self.observerManager = KVOManager()
        super.init(coder: aDecoder)
        addContentSizeObserver()
    }
    
    deinit {
        observerManager.removeObserver(self, from: self, forKeyPath: keyPath)
    }
    
    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?) {
        
        if self.keyPath == keyPath {
            if let new = change?[.newKey] as? NSValue,
                let old = change?[.oldKey] as? NSValue,
                new != old {
                invalidateIntrinsicContentSize()
            }
        }
    }
    
    private func addContentSizeObserver() {
        observerManager.addObserver(self,
                                    to: self,
                                    forKeyPath: keyPath,
                                    options: [.new, .old],
                                    context: nil)
    }
    
    override var intrinsicContentSize: CGSize {
        return contentSize
    }
}

protocol ObserverManager {
    
    func addObserver(_ observer: NSObject,
                     to receiver: NSObject,
                     forKeyPath keyPath: String,
                     options: NSKeyValueObservingOptions,
                     context: UnsafeMutableRawPointer?)
    
    func removeObserver(_ observer: NSObject,
                        from receiver: NSObject,
                        forKeyPath keyPath: String)
}

final class KVOManager: ObserverManager {
    
    func addObserver(_ observer: NSObject,
                     to receiver: NSObject,
                     forKeyPath keyPath: String,
                     options: NSKeyValueObservingOptions,
                     context: UnsafeMutableRawPointer?) {
        receiver.addObserver(observer, forKeyPath: keyPath, options: options, context: context)
    }
    
    func removeObserver(_ observer: NSObject, from receiver: NSObject, forKeyPath keyPath: String) {
        receiver.removeObserver(observer, forKeyPath: keyPath)
    }
}
