//
//  Scaler3x.swift
//  sxBRZ
//
// Created by T!T@N on 04.26.16.
//

import Foundation

struct Scaler3x<T:ColorGradient> : Scaler {
    static var scale: Int {
        get {
            return 3
        }
    }

    static func alphaGrad(M: UInt32, _ N:UInt32, _ pixBack: UnsafeMutablePointer<UInt32>, _ pixFront: UInt32) {
        T.alphaGrad(M, N, pixBack, pixFront)
    }

    static func blendLineShallow(col: UInt32, inout _ out: OutputMatrix) {
        alphaGrad(1,4,out.ref(UInt(scale)-1, 0), col)
        alphaGrad(1,4,out.ref(UInt(scale)-2, 2), col)

        alphaGrad(3,4,out.ref(UInt(scale)-1, 1), col)
        out.ref(UInt(scale)-1, 2)[0] = col
    }

    static func blendLineSteep(col: UInt32, inout _ out: OutputMatrix) {
        alphaGrad(1,4,out.ref(0, UInt(scale)-1), col)
        alphaGrad(1,4,out.ref(2, UInt(scale)-2), col)

        alphaGrad(3,4,out.ref(1, UInt(scale)-1), col)
        out.ref(2, UInt(scale)-1)[0] = col
    }

    static func blendLineSteepAndShallow(col: UInt32, inout _ out:OutputMatrix) {
        alphaGrad(1,4,out.ref(2, 0), col)
        alphaGrad(1,4,out.ref(0, 2), col)
        alphaGrad(3,4,out.ref(2, 1), col)
        alphaGrad(3,4,out.ref(1, 2), col)
        out.ref(2, 2)[0] = col
    }

    static func blendLineDiagonal(col: UInt32, inout _ out: OutputMatrix) {
        alphaGrad(1,8,out.ref(1, 2), col)
        alphaGrad(1,8,out.ref(2, 1), col)
        alphaGrad(7,8,out.ref(2, 2), col)
    }

    static func blendCorner(col: UInt32, inout _ out: OutputMatrix) {
        alphaGrad(45,100,out.ref(2, 2), col)    //exact: 0.4545939598
    }
}