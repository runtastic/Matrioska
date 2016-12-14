//
//  UIColor+HEX.swift
//  Matrioska
//
//  Created by Alex Manzella on 14/12/16.
//  Copyright © 2016 runtastic. All rights reserved.
//

import Foundation

extension UIColor {

    private convenience init(hex: Int) {
        func normalized(_ value: Int) -> CGFloat {
            return CGFloat(value) / 255.0
        }

        self.init(
            red: normalized((hex >> 16) & 0xff),
            green: normalized((hex >> 8) & 0xff),
            blue: normalized(hex & 0xff),
            alpha: 1
        )
    }

    /// Initialize a color if the input strings represents an hex color
    ///
    /// - Parameter hexString: A Strign representing an hex color.
    ///     Alpha not supported and compact form not supported.
    ///     Valid format: "0x123456" or "123456"
    public convenience init?(hexString: String) {
        let hexString = hexString
        var hexValue = UInt32()

        guard Scanner(string: hexString).scanHexInt32(&hexValue) else {
            return nil
        }

        self.init(hex: Int(hexValue))
    }
}
