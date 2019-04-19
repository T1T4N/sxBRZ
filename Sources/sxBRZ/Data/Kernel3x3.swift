//
//  Kernel3.swift
//  sxBRZ
//
//  Created by Robert Armenski on 19.04.19.
//  Copyright © 2019 TitanTech. All rights reserved.
//

import Foundation

// swiftlint:disable identifier_name
struct Kernel3x3 {
    let
    a: UInt32, b: UInt32, c: UInt32,
    d: UInt32, e: UInt32, f: UInt32,
    g: UInt32, h: UInt32, i: UInt32
}

extension Kernel3x3: CustomStringConvertible {
    var description: String {
        return String(format: "%d %d %d %d %d %d %d %d %d",
                      self.a, self.b, self.c,
                      self.d, self.e, self.f,
                      self.g, self.h, self.i)
    }
}
