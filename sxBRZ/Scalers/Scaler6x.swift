//
//  Scaler6x.swift
//  sxBRZ
//
// Created by T!T@N on 04.26.16.
//

import Foundation

struct Scaler6x<T:ColorGradient>: Scaler {
    static var scale: Int {
        get {
            return 6
        }
    }

    static func alphaGrad(M: UInt32, _ N: UInt32, _ pixBack: UnsafeMutablePointer<UInt32>, _ pixFront: UInt32) {
        T.alphaGrad(M, N, pixBack, pixFront)
    }

    static func blendLineShallow(col: UInt32, inout _ out: OutputMatrix) {
        alphaGrad(1, 4, out.ref(UInt(scale) - 1, 0), col)
        alphaGrad(1, 4, out.ref(UInt(scale) - 2, 2), col)
        alphaGrad(1, 4, out.ref(UInt(scale) - 3, 4), col)

        alphaGrad(3, 4, out.ref(UInt(scale) - 1, 1), col)
        alphaGrad(3, 4, out.ref(UInt(scale) - 2, 3), col)
        alphaGrad(3, 4, out.ref(UInt(scale) - 3, 5), col)

        out.ref(UInt(scale) - 1, 2)[0] = col
        out.ref(UInt(scale) - 1, 3)[0] = col
        out.ref(UInt(scale) - 1, 4)[0] = col
        out.ref(UInt(scale) - 1, 5)[0] = col

        out.ref(UInt(scale) - 2, 4)[0] = col
        out.ref(UInt(scale) - 2, 5)[0] = col
    }

    static func blendLineSteep(col: UInt32, inout _ out: OutputMatrix) {
        alphaGrad(1, 4, out.ref(0, UInt(scale) - 1), col)
        alphaGrad(1, 4, out.ref(2, UInt(scale) - 2), col)
        alphaGrad(1, 4, out.ref(4, UInt(scale) - 3), col)

        alphaGrad(3, 4, out.ref(1, UInt(scale) - 1), col)
        alphaGrad(3, 4, out.ref(3, UInt(scale) - 2), col)
        alphaGrad(3, 4, out.ref(5, UInt(scale) - 3), col)

        out.ref(2, UInt(scale) - 1)[0] = col
        out.ref(3, UInt(scale) - 1)[0] = col
        out.ref(4, UInt(scale) - 1)[0] = col
        out.ref(5, UInt(scale) - 1)[0] = col

        out.ref(4, UInt(scale) - 2)[0] = col
        out.ref(5, UInt(scale) - 2)[0] = col
    }

    static func blendLineSteepAndShallow(col: UInt32, inout _ out: OutputMatrix) {
        alphaGrad(1, 4, out.ref(0, UInt(scale) - 1), col)
        alphaGrad(1, 4, out.ref(2, UInt(scale) - 2), col)
        alphaGrad(3, 4, out.ref(1, UInt(scale) - 1), col)
        alphaGrad(3, 4, out.ref(3, UInt(scale) - 2), col)

        alphaGrad(1, 4, out.ref(UInt(scale) - 1, 0), col)
        alphaGrad(1, 4, out.ref(UInt(scale) - 2, 2), col)
        alphaGrad(3, 4, out.ref(UInt(scale) - 1, 1), col)
        alphaGrad(3, 4, out.ref(UInt(scale) - 2, 3), col)

        out.ref(2, UInt(scale) - 1)[0] = col
        out.ref(3, UInt(scale) - 1)[0] = col
        out.ref(4, UInt(scale) - 1)[0] = col
        out.ref(5, UInt(scale) - 1)[0] = col

        out.ref(4, UInt(scale) - 2)[0] = col
        out.ref(5, UInt(scale) - 2)[0] = col

        out.ref(UInt(scale) - 1, 2)[0] = col
        out.ref(UInt(scale) - 1, 3)[0] = col
    }

    static func blendLineDiagonal(col: UInt32, inout _ out: OutputMatrix) {
        alphaGrad(1, 2, out.ref(UInt(scale) - 1, UInt(scale / 2)), col)
        alphaGrad(1, 2, out.ref(UInt(scale) - 2, UInt(scale / 2) + 1), col)
        alphaGrad(1, 2, out.ref(UInt(scale) - 3, UInt(scale / 2) + 2), col)

        out.ref(UInt(scale) - 2, UInt(scale) - 1)[0] = col
        out.ref(UInt(scale) - 1, UInt(scale) - 1)[0] = col
        out.ref(UInt(scale) - 1, UInt(scale) - 2)[0] = col
    }

    static func blendCorner(col: UInt32, inout _ out: OutputMatrix) {
        alphaGrad(97, 100, out.ref(5, 5), col)  //exact: 0.9711013910
        alphaGrad(42, 100, out.ref(4, 5), col)  //0.4236372243
        alphaGrad(42, 100, out.ref(5, 4), col)  //0.4236372243
        alphaGrad(6, 100, out.ref(5, 3), col)  //0.05652034508
        alphaGrad(6, 100, out.ref(3, 5), col)  //0.05652034508
    }
}