//
//  Scaler2x.swift
//  sxBRZ
//
// Created by T!T@N on 04.26.16.
//

import Foundation

struct Scaler2x<T:ColorGradient>: Scaler {
    static var scale: Int {
        get {
            return 2
        }
    }

    static func alphaGrad(M: UInt32, _ N: UInt32, _ pixBack: UnsafeMutablePointer<UInt32>, _ pixFront: UInt32) {
        T.alphaGrad(M, N, pixBack, pixFront)
    }

    static func blendLineShallow(col: UInt32, inout _ out: OutputMatrix) {
        alphaGrad(1, 4, out.ref(UInt(scale) - 1, 0), col)
        alphaGrad(3, 4, out.ref(UInt(scale) - 1, 1), col)
    }

    static func blendLineSteep(col: UInt32, inout _ out: OutputMatrix) {
        alphaGrad(1, 4, out.ref(0, UInt(scale) - 1), col)
        alphaGrad(3, 4, out.ref(1, UInt(scale) - 1), col)
    }

    static func blendLineSteepAndShallow(col: UInt32, inout _ out: OutputMatrix) {
        alphaGrad(1, 4, out.ref(1, 0), col)
        alphaGrad(1, 4, out.ref(0, 1), col)
        alphaGrad(5, 6, out.ref(1, 1), col)
    }

    static func blendLineDiagonal(col: UInt32, inout _ out: OutputMatrix) {
        alphaGrad(1, 2, out.ref(1, 1), col)
    }

    static func blendCorner(col: UInt32, inout _ out: OutputMatrix) {
        alphaGrad(21, 100, out.ref(1, 1), col)
    }
}
