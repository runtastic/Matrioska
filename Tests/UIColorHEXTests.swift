//
//  UIColorHEXTests.swift
//  Matrioska
//
//  Created by Alex Manzella on 14/12/16.
//  Copyright © 2016 runtastic. All rights reserved.
//

import XCTest
import Quick
import Nimble
import Nimble_Snapshots
import FBSnapshotTestCase
import Matrioska

class UIColorHEXTests: QuickSpec {
    override func spec() {
        describe("UIColor+HEX") {
            it("should ignore strings not representing an hex value") {
                let color = UIColor(hexString: "£$$$%")
                expect(color).to(beNil())
            }

            it("should get color form an hex string prefixed with 0x") {
                let color = UIColor(hexString: "0x1234AB")
                expect(color?.components) == ColorRepresentation(18, 52, 171)
            }

            it("should get color form an hex string not prefixed with 0x") {
                let color = UIColor(hexString: "1234AB")
                expect(color?.components) == ColorRepresentation(18, 52, 171)
            }
        }
    }
}

struct ColorRepresentation: Equatable {
    let red: Int
    let green: Int
    let blue: Int

    init(_ red: Int, _ green: Int, _ blue: Int) {
        self.red = red
        self.green = green
        self.blue = blue
    }

    static func == (lhs: ColorRepresentation, rhs: ColorRepresentation) -> Bool {
        return lhs.red == rhs.red && lhs.green == rhs.green && lhs.blue == rhs.blue
    }
}

extension UIColor {
    var components: ColorRepresentation {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0

        getRed(&red, green: &green, blue: &blue, alpha: nil)
        return ColorRepresentation(Int(red * 255), Int(green * 255), Int(blue * 255))
    }
}
