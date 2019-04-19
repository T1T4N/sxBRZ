//
//  Scaler.swift
//  sxBRZ
//
//  Created by T!T@N on 04.25.16.
//

import Foundation

protocol Scaler {
    static var scale: Int { get }
    static func blendLineShallow(_ col: UInt32, _ out: inout OutputMatrix)
    static func blendLineShallow(_ col: UInt32, _ ref: (UInt, UInt) -> UnsafeMutablePointer<UInt32>)
    static func blendLineSteep(_ col: UInt32, _ out: inout OutputMatrix)
    static func blendLineSteep(_ col: UInt32, _ ref: (UInt, UInt) -> UnsafeMutablePointer<UInt32>)
    static func blendLineSteepAndShallow(_ col: UInt32, _ out:inout OutputMatrix)
    static func blendLineSteepAndShallow(_ col: UInt32, _ ref: (UInt, UInt) -> UnsafeMutablePointer<UInt32>)
    static func blendLineDiagonal(_ col: UInt32, _ out: inout OutputMatrix)
    static func blendLineDiagonal(_ col: UInt32, _ ref: (UInt, UInt) -> UnsafeMutablePointer<UInt32>)
    static func blendCorner(_ col: UInt32, _ out: inout OutputMatrix)
    static func blendCorner(_ col: UInt32, _ ref: (UInt, UInt) -> UnsafeMutablePointer<UInt32>)
}
