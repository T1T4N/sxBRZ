//
//  ColorGradientRGB.swift
//  sxBRZ
//
// Created by T!T@N on 04.26.16.
//

import Foundation

// swiftlint:disable identifier_name
struct ColorGradientRGB: ColorGradient {
    static let instance: ColorGradient = ColorGradientRGB()

    func alphaGrad(_ M: UInt32, _ N: UInt32,
                   _ pixBack: RawPixel, _ pixFront: RawPixel) -> RawPixel {
        return gradientRGB(M, N, pixFront, pixBack)
    }
}

func gradientRGB(_ M: UInt32, _ N: UInt32,
                 _ pixFront: RawPixel, _ pixBack: RawPixel) -> RawPixel {
    assert(0 < M && M < N && N <= 1000, "")

    func calcColor(_ colFront: RawPixelColor, _ colBack: RawPixelColor) -> RawPixelColor {
        return RawPixelColor((RawPixel(colFront) * M + RawPixel(colBack) * (N - M)) / N)
    }

    return RawPixel.from(
        r: calcColor(pixFront.red, pixBack.red),
        g: calcColor(pixFront.green, pixBack.green),
        b: calcColor(pixFront.blue, pixBack.blue)
    )
}
