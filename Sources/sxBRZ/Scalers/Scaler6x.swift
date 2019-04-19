//
//  Scaler6x.swift
//  sxBRZ
//
// Created by T!T@N on 04.26.16.
//

import Foundation

struct Scaler6x: Scaler {
    let gradient: ColorGradient
    var scale: Int { return 6 }

    func alphaGrad(_ M: UInt32, _ N: UInt32,
                   _ pixBack: UnsafeMutablePointer<UInt32>, _ pixFront: UInt32) {
        gradient.alphaGrad(M, N, &pixBack[0], pixFront)
    }

    func blendLineShallow(_ col: UInt32, _ out: inout OutputMatrix) {
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

    func blendLineShallow(_ col: UInt32, _ ref: (UInt, UInt) -> UnsafeMutablePointer<UInt32>) {
        alphaGrad(1, 4, ref(UInt(scale) - 1, 0), col)
        alphaGrad(1, 4, ref(UInt(scale) - 2, 2), col)
        alphaGrad(1, 4, ref(UInt(scale) - 3, 4), col)

        alphaGrad(3, 4, ref(UInt(scale) - 1, 1), col)
        alphaGrad(3, 4, ref(UInt(scale) - 2, 3), col)
        alphaGrad(3, 4, ref(UInt(scale) - 3, 5), col)

        ref(UInt(scale) - 1, 2)[0] = col
        ref(UInt(scale) - 1, 3)[0] = col
        ref(UInt(scale) - 1, 4)[0] = col
        ref(UInt(scale) - 1, 5)[0] = col

        ref(UInt(scale) - 2, 4)[0] = col
        ref(UInt(scale) - 2, 5)[0] = col
    }

    func blendLineSteep(_ col: UInt32, _ out: inout OutputMatrix) {
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

    func blendLineSteep(_ col: UInt32, _ ref: (UInt, UInt) -> UnsafeMutablePointer<UInt32>) {
        alphaGrad(1, 4, ref(0, UInt(scale) - 1), col)
        alphaGrad(1, 4, ref(2, UInt(scale) - 2), col)
        alphaGrad(1, 4, ref(4, UInt(scale) - 3), col)

        alphaGrad(3, 4, ref(1, UInt(scale) - 1), col)
        alphaGrad(3, 4, ref(3, UInt(scale) - 2), col)
        alphaGrad(3, 4, ref(5, UInt(scale) - 3), col)

        ref(2, UInt(scale) - 1)[0] = col
        ref(3, UInt(scale) - 1)[0] = col
        ref(4, UInt(scale) - 1)[0] = col
        ref(5, UInt(scale) - 1)[0] = col

        ref(4, UInt(scale) - 2)[0] = col
        ref(5, UInt(scale) - 2)[0] = col
    }

    func blendLineSteepAndShallow(_ col: UInt32, _ out: inout OutputMatrix) {
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

    func blendLineSteepAndShallow(_ col: UInt32, _ ref: (UInt, UInt) -> UnsafeMutablePointer<UInt32>) {
        alphaGrad(1, 4, ref(0, UInt(scale) - 1), col)
        alphaGrad(1, 4, ref(2, UInt(scale) - 2), col)
        alphaGrad(3, 4, ref(1, UInt(scale) - 1), col)
        alphaGrad(3, 4, ref(3, UInt(scale) - 2), col)

        alphaGrad(1, 4, ref(UInt(scale) - 1, 0), col)
        alphaGrad(1, 4, ref(UInt(scale) - 2, 2), col)
        alphaGrad(3, 4, ref(UInt(scale) - 1, 1), col)
        alphaGrad(3, 4, ref(UInt(scale) - 2, 3), col)

        ref(2, UInt(scale) - 1)[0] = col
        ref(3, UInt(scale) - 1)[0] = col
        ref(4, UInt(scale) - 1)[0] = col
        ref(5, UInt(scale) - 1)[0] = col

        ref(4, UInt(scale) - 2)[0] = col
        ref(5, UInt(scale) - 2)[0] = col

        ref(UInt(scale) - 1, 2)[0] = col
        ref(UInt(scale) - 1, 3)[0] = col
    }

    func blendLineDiagonal(_ col: UInt32, _ out: inout OutputMatrix) {
        alphaGrad(1, 2, out.ref(UInt(scale) - 1, UInt(scale / 2)), col)
        alphaGrad(1, 2, out.ref(UInt(scale) - 2, UInt(scale / 2) + 1), col)
        alphaGrad(1, 2, out.ref(UInt(scale) - 3, UInt(scale / 2) + 2), col)

        out.ref(UInt(scale) - 2, UInt(scale) - 1)[0] = col
        out.ref(UInt(scale) - 1, UInt(scale) - 1)[0] = col
        out.ref(UInt(scale) - 1, UInt(scale) - 2)[0] = col
    }

    func blendLineDiagonal(_ col: UInt32, _ ref: (UInt, UInt) -> UnsafeMutablePointer<UInt32>) {
        alphaGrad(1, 2, ref(UInt(scale) - 1, UInt(scale / 2)), col)
        alphaGrad(1, 2, ref(UInt(scale) - 2, UInt(scale / 2) + 1), col)
        alphaGrad(1, 2, ref(UInt(scale) - 3, UInt(scale / 2) + 2), col)

        ref(UInt(scale) - 2, UInt(scale) - 1)[0] = col
        ref(UInt(scale) - 1, UInt(scale) - 1)[0] = col
        ref(UInt(scale) - 1, UInt(scale) - 2)[0] = col
    }

    func blendCorner(_ col: UInt32, _ out: inout OutputMatrix) {
        alphaGrad(97, 100, out.ref(5, 5), col)  //exact: 0.9711013910
        alphaGrad(42, 100, out.ref(4, 5), col)  //0.4236372243
        alphaGrad(42, 100, out.ref(5, 4), col)  //0.4236372243
        alphaGrad(6, 100, out.ref(5, 3), col)  //0.05652034508
        alphaGrad(6, 100, out.ref(3, 5), col)  //0.05652034508
    }

    func blendCorner(_ col: UInt32, _ ref: (UInt, UInt) -> UnsafeMutablePointer<UInt32>) {
        alphaGrad(97, 100, ref(5, 5), col)  //exact: 0.9711013910
        alphaGrad(42, 100, ref(4, 5), col)  //0.4236372243
        alphaGrad(42, 100, ref(5, 4), col)  //0.4236372243
        alphaGrad(6, 100, ref(5, 3), col)  //0.05652034508
        alphaGrad(6, 100, ref(3, 5), col)  //0.05652034508
    }
}
