//
//  ColorGradientARGB.swift
//  sxBRZ
//
// Created by T!T@N on 04.26.16.
//

import Foundation

struct ColorGradientARGB: ColorGradient {
    static func alphaGrad(_ M: UInt32, _ N: UInt32, _ pixBack: UInt32, _ pixFront: UInt32) -> UInt32{
        return gradientARGB(M, N, pixFront, pixBack)
    }
    static func alphaGrad(_ M: UInt32, _ N: UInt32, _ pixBack: inout UInt32, _ pixFront: UInt32) {
        pixBack = gradientARGB(M, N, pixFront, pixBack)
    }
    static func alphaGrad(_ M: UInt32, _ N: UInt32, pixBack: UnsafeMutablePointer<UInt32>, _ pixFront: UInt32) {
        pixBack[0] = gradientARGB(M, N, pixFront, pixBack[0])
    }
}

func gradientARGB(_ M: UInt32, _ N: UInt32, _ pixFront: UInt32, _ pixBack: UInt32) -> UInt32 {
    assert(0 < M && M < N && N <= 1000, "")
    
    var weightFront:UInt32 = UInt32(getAlpha(pixFront)) * M
    var weightBack:UInt32 = UInt32(getAlpha(pixBack)) * (N - M)
    var weightSum:UInt32 = weightFront + weightBack
    if weightSum == 0 {
        return 0;
    }
    
    func calcColor(_ colFront: CUnsignedChar, _ colBack: CUnsignedChar) -> CUnsignedChar {
        return CUnsignedChar((UInt32(colFront) * weightFront + UInt32(colBack) * weightBack) / weightSum);
    }
    return makePixel(
        CUnsignedChar(weightSum / N),
        calcColor(getRed  (pixFront), getRed  (pixBack)),
        calcColor(getGreen(pixFront), getGreen(pixBack)),
        calcColor(getBlue (pixFront), getBlue (pixBack))
    )
}
