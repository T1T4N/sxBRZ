//
//  Pixels.swift
//  sxBRZ
//
//  Created by Robert Armenski on 19.04.19.
//  Copyright © 2019 TitanTech. All rights reserved.
//

import Foundation

public typealias RawPixel = UInt32
public typealias RawPixelColor = CUnsignedChar

private func getByte(_ N: UInt32, val: RawPixel) -> RawPixelColor {
    return RawPixelColor((val >> (8 * N)) & 0xff)
}

private func getAlpha(_ pix: RawPixel) -> RawPixelColor {
    return getByte(3, val: pix)
}

private func getRed(_ pix: RawPixel) -> RawPixelColor {
    return getByte(2, val: pix)
}

private func getGreen(_ pix: RawPixel) -> RawPixelColor {
    return getByte(1, val: pix)
}

private func getBlue(_ pix: RawPixel) -> RawPixelColor {
    return getByte(0, val: pix)
}

private func makePixel(_ r: RawPixelColor,
                       _ g: RawPixelColor,
                       _ b: RawPixelColor) -> RawPixel {
    return (UInt32(r) << 16) | (UInt32(g) << 8) | UInt32(b)
}

private func makePixel(_ a: RawPixelColor,
                       _ r: RawPixelColor,
                       _ g: RawPixelColor,
                       _ b: RawPixelColor) -> RawPixel {
    return (UInt32(a) << 24) | (UInt32(r) << 16) | (UInt32(g) << 8) | UInt32(b)
}


extension RawPixel {
    public static func from(r: RawPixelColor,
                            g: RawPixelColor,
                            b: RawPixelColor) -> RawPixel {
        return makePixel(r, g, b)
    }

    public static func from(a: RawPixelColor,
                            r: RawPixelColor,
                            g: RawPixelColor,
                            b: RawPixelColor) -> RawPixel {
        return makePixel(a, r, g, b)
    }
}

extension RawPixel {
    public var alpha: RawPixelColor { return getAlpha(self) }
    public var red: RawPixelColor { return getRed(self) }
    public var green: RawPixelColor { return getGreen(self) }
    public var blue: RawPixelColor { return getBlue(self) }
}
