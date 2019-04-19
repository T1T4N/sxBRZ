//
//  ColorGradientARGB.swift
//  sxBRZ
//
// Created by T!T@N on 04.26.16.
//

import Foundation

// swiftlint:disable identifier_name
struct ColorGradientARGB: ColorGradient {
    static let instance = ColorGradientARGB()

    func alphaGrad(_ M: UInt32, _ N: UInt32,
                   _ pixBack: UInt32, _ pixFront: UInt32) -> UInt32 {
        return gradientARGB(M, N, pixFront, pixBack)
    }

    func alphaGrad(_ M: UInt32, _ N: UInt32,
                   _ pixBack: inout UInt32, _ pixFront: UInt32) {
        pixBack = gradientARGB(M, N, pixFront, pixBack)
    }
    func alphaGrad(_ M: UInt32, _ N: UInt32,
                   pixBack: UnsafeMutablePointer<UInt32>, _ pixFront: UInt32) {
        pixBack[0] = gradientARGB(M, N, pixFront, pixBack[0])
    }
}

func gradientARGB(_ M: UInt32, _ N: UInt32,
                  _ pixFront: UInt32, _ pixBack: UInt32) -> UInt32 {
    assert(0 < M && M < N && N <= 1000, "")

    let weightFront = UInt32(getAlpha(pixFront)) * M
    let weightBack = UInt32(getAlpha(pixBack)) * (N - M)
    let weightSum = weightFront + weightBack
    guard weightSum != 0 else { return 0 }

    func calcColor(_ colFront: CUnsignedChar, _ colBack: CUnsignedChar) -> CUnsignedChar {
        return CUnsignedChar((UInt32(colFront) * weightFront + UInt32(colBack) * weightBack) / weightSum)
    }

    return makePixel(
        CUnsignedChar(weightSum / N),
        calcColor(getRed  (pixFront), getRed  (pixBack)),
        calcColor(getGreen(pixFront), getGreen(pixBack)),
        calcColor(getBlue (pixFront), getBlue (pixBack))
    )
}
