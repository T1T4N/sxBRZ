//
//  ColorGradient.swift
//  sxBRZ
//
//  Created by T!T@N on 04.25.16.
//

import Foundation

// swiftlint:disable identifier_name
protocol ColorGradient {
    static var instance: ColorGradient { get }

    func alphaGrad(_ M: UInt32, _ N: UInt32,
                   _ pixBack: UInt32, _ pixFront: UInt32) -> UInt32
    func alphaGrad(_ M: UInt32, _ N: UInt32,
                   _ pixBack: inout UInt32, _ pixFront: UInt32)
    func alphaGrad(_ M: UInt32, _ N: UInt32,
                   pixBack: UnsafeMutablePointer<UInt32>, _ pixFront: UInt32)
}
