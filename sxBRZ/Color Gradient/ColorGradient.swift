//
//  ColorGradient.swift
//  sxBRZ
//
//  Created by T!T@N on 04.25.16.
//

import Foundation

protocol ColorGradient {
    static func alphaGrad(M: UInt32, _ N: UInt32, _ pixBack: UnsafeMutablePointer<UInt32>, _ pixFront: UInt32)
}
