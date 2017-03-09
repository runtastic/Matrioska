//
//  ClusterLayout.swift
//  Matrioska
//
//  Created by Alex Manzella on 15/11/16.
//  Copyright © 2016 runtastic. All rights reserved.
//

import Foundation

/// The standard library clusters
/// 1. `TabBarCluster`: A tabBar cluster component
/// 2. `StackCluster`: A stack cluster component
///
/// See the documentation of the clusters for more informations and configuration options.
public enum ClusterLayout {
    
    /// Custom enum to handle orientation values
    public enum Orientation: String {
        case horizontal
        case vertical
    }
}

/// This extension allows us to map our custom orientation enum values to UILayoutConstraintAxis
extension ClusterLayout.Orientation {
    var layoutConstraintAxis: UILayoutConstraintAxis {
        switch self {
        case .horizontal: return .horizontal
        case .vertical: return .vertical
        }
    }
}
