//
//  ColorGradientARGB.swift
//  sxBRZ
//
// Created by T!T@N on 04.26.16.
//

import Foundation

// swiftlint:disable identifier_name
struct ColorGradientARGB: ColorGradient {
    static let instance: ColorGradient = ColorGradientARGB()

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
                  _ pixFront: RawPixel, _ pixBack: RawPixel) -> UInt32 {
    assert(0 < M && M < N && N <= 1000, "")

    let weightFront = UInt32(pixFront.alpha) * M
    let weightBack = UInt32(pixBack.alpha) * (N - M)
    let weightSum = weightFront + weightBack
    guard weightSum != 0 else { return 0 }

    func calcColor(_ colFront: RawPixelColor, _ colBack: RawPixelColor) -> RawPixelColor {
        return RawPixelColor((RawPixel(colFront) * weightFront + RawPixel(colBack) * weightBack) / weightSum)
    }

    return RawPixel.from(
        a: RawPixelColor(weightSum / N),
        r: calcColor(pixFront.red, pixBack.red),
        g: calcColor(pixFront.green, pixBack.green),
        b: calcColor(pixFront.blue, pixBack.blue)
    )
}
