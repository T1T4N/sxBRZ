//
//  ColorGradientRGB.swift
//  sxBRZ
//
// Created by T!T@N on 04.26.16.
//

import Foundation

// swiftlint:disable identifier_name
struct ColorGradientRGB: ColorGradient {
    static let instance = ColorGradientRGB()

    func alphaGrad(_ M: UInt32, _ N: UInt32,
                   _ pixBack: UInt32, _ pixFront: UInt32) -> UInt32 {
        return gradientRGB(M, N, pixFront, pixBack)
    }

    func alphaGrad(_ M: UInt32, _ N: UInt32,
                   _ pixBack: inout UInt32, _ pixFront: UInt32) {
        pixBack = gradientRGB(M, N, pixFront, pixBack)
    }

    func alphaGrad(_ M: UInt32, _ N: UInt32,
                   pixBack: UnsafeMutablePointer<UInt32>, _ pixFront: UInt32) {
        pixBack[0] = gradientRGB(M, N, pixFront, pixBack[0])
    }
}

func gradientRGB(_ M: UInt32, _ N: UInt32,
                 _ pixFront: UInt32, _ pixBack: UInt32) -> UInt32 {
    assert(0 < M && M < N && N <= 1000, "")

    func calcColor(_ colFront: CUnsignedChar, _ colBack: CUnsignedChar) -> CUnsignedChar {
        return CUnsignedChar((UInt32(colFront) * M + UInt32(colBack) * (N - M)) / N)
    }

    return makePixel(
        calcColor(getRed  (pixFront), getRed  (pixBack)),
        calcColor(getGreen(pixFront), getGreen(pixBack)),
        calcColor(getBlue (pixFront), getBlue (pixBack))
    )
}
