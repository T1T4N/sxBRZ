//
//  ColorGradientARGB.swift
//  sxBRZ
//
// Created by T!T@N on 04.26.16.
//

import Foundation

struct ColorGradientARGB: ColorGradient {
    static func alphaGrad(M: UInt32, _ N: UInt32, _ pixBack: UnsafeMutablePointer<UInt32>, _ pixFront: UInt32) {
        let pbVal = pixBack[0]
        let ret = gradientARGB(M, N, pixFront, pbVal)
        pixBack[0] = ret
    }
}