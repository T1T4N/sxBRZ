//
//  Scaler.swift
//  sxBRZ
//
//  Created by T!T@N on 04.25.16.
//

import Foundation

protocol Scaler {
    static var scale: Int { get }
    static func blendLineShallow(col: UInt32, inout _ out: OutputMatrix)
    static func blendLineSteep(col: UInt32, inout _ out: OutputMatrix)
    static func blendLineSteepAndShallow(col: UInt32, inout _ out:OutputMatrix)
    static func blendLineDiagonal(col: UInt32, inout _ out: OutputMatrix)
    static func blendCorner(col: UInt32, inout _ out: OutputMatrix)
}