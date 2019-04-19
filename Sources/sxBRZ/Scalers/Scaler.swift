//
//  Scaler.swift
//  sxBRZ
//
//  Created by T!T@N on 04.25.16.
//

import Foundation

protocol Scaler {
    var gradient: ColorGradient { get }
    var scale: Int { get }

    func blendLineShallow(_ col: UInt32, _ out: inout OutputMatrix)
    func blendLineShallow(_ col: UInt32, _ ref: (UInt, UInt) -> UnsafeMutablePointer<UInt32>)

    func blendLineSteep(_ col: UInt32, _ out: inout OutputMatrix)
    func blendLineSteep(_ col: UInt32, _ ref: (UInt, UInt) -> UnsafeMutablePointer<UInt32>)

    func blendLineSteepAndShallow(_ col: UInt32, _ out:inout OutputMatrix)
    func blendLineSteepAndShallow(_ col: UInt32, _ ref: (UInt, UInt) -> UnsafeMutablePointer<UInt32>)

    func blendLineDiagonal(_ col: UInt32, _ out: inout OutputMatrix)
    func blendLineDiagonal(_ col: UInt32, _ ref: (UInt, UInt) -> UnsafeMutablePointer<UInt32>)

    func blendCorner(_ col: UInt32, _ out: inout OutputMatrix)
    func blendCorner(_ col: UInt32, _ ref: (UInt, UInt) -> UnsafeMutablePointer<UInt32>)
}
