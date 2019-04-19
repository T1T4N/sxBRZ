//
//  BlendType.swift
//  sxBRZ
//
//  Created by T!T@N on 04.25.16.
//

import Foundation

enum BlendType: UInt8 {
    case none = 0
    case normal = 1   //a normal indication to blend
    case dominant = 2 //a strong indication to blend
    //case undefined
    //attention: BlendType must fit into the value range of 2 bit!!!
}

extension RawPixelColor {
    var topL: BlendType { return BlendType(rawValue: ((0x3 & self) % 3))! }
    var topR: BlendType { return BlendType(rawValue: ((0x3 & (self >> 2)) % 3))! }
    var bottomR: BlendType { return BlendType(rawValue: ((0x3 & (self >> 4)) % 3))! }
    var bottomL: BlendType { return BlendType(rawValue: ((0x3 & (self >> 6)) % 3))! }

    mutating func setTopL(blend: BlendType) {
        self |= blend.rawValue
    }

    mutating func setTopR(blend: BlendType) {
        self |= (blend.rawValue << 2)
    }

    mutating func setBottomR(blend: BlendType) {
        self |= (blend.rawValue << 4)
    }

    mutating func setBottomL(blend: BlendType) {
        self |= (blend.rawValue << 6)
    }

    var blendingNeeded: Bool { return self != 0 }
}
