//
//  ColorGradientARGB.swift
//  sxBRZ
//
// Created by T!T@N on 04.26.16.
//

import Foundation

// swiftlint:disable identifier_name
class ColorGradientARGB: ColorGradient {
    static let instance: ColorGradient = ColorGradientARGB()

    func alphaGrad(_ M: UInt32, _ N: UInt32,
                   _ pixBack: RawPixel, _ pixFront: RawPixel) -> RawPixel {
        return gradientARGB(M, N, pixFront, pixBack)
    }
}

func gradientARGB(_ M: UInt32, _ N: UInt32,
                  _ pixFront: RawPixel, _ pixBack: RawPixel) -> RawPixel {
    assert(0 < M && M < N && N <= 1000, "")

    let weightFront = RawPixel(pixFront.alpha) * M
    let weightBack = RawPixel(pixBack.alpha) * (N - M)
    let weightSum = weightFront + weightBack
    guard weightSum != 0 else { return 0 }

    func calcColor(_ colFront: RawPixelColor,
                   _ colBack: RawPixelColor) -> RawPixelColor {
        return RawPixelColor((RawPixel(colFront) * weightFront + RawPixel(colBack) * weightBack) / weightSum)
    }

    return RawPixel.from(
        a: RawPixelColor(weightSum / N),
        r: calcColor(pixFront.red, pixBack.red),
        g: calcColor(pixFront.green, pixBack.green),
        b: calcColor(pixFront.blue, pixBack.blue)
    )
}
