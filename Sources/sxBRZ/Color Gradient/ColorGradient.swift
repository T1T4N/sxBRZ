//
//  ColorGradient.swift
//  sxBRZ
//
//  Created by T!T@N on 04.25.16.
//

import Foundation

// swiftlint:disable identifier_name
protocol ColorGradient: class {
    static var instance: ColorGradient { get }

    func alphaGrad(_ M: UInt32, _ N: UInt32,
                   _ pixBack: RawPixel, _ pixFront: RawPixel) -> UInt32
}

extension ColorGradient {
    func alphaGrad(_ M: UInt32, _ N: UInt32,
                   _ pixBack: inout RawPixel, _ pixFront: RawPixel) {
        pixBack = alphaGrad(M, N, pixBack, pixFront)
    }
}
