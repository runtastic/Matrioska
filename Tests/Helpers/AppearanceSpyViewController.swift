//
//  AppearanceSpyViewController.swift
//  Matrioska
//
//  Created by Alex Manzella on 28/11/16.
//  Copyright © 2016 runtastic. All rights reserved.
//

import Foundation
import UIKit

final class AppearanceSpyViewController: UIViewController {
    typealias AppearanceSpy = (UIView) -> Void
    
    var willAppear: AppearanceSpy?
    var didAppear: AppearanceSpy?
    var willDisappear: AppearanceSpy?
    var didDisappear: AppearanceSpy?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        willAppear?(view)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        didAppear?(view)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        willDisappear?(view)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        didDisappear?(view)
    }
}
