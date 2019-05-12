//
//  Scaler5x.swift
//  sxBRZ
//
// Created by T!T@N on 04.26.16.
//

import Foundation

// swiftlint:disable identifier_name
struct Scaler5x: Scaler {
    let gradient: ColorGradient
    var scale: Int { return 5 }

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

        out.ref(UInt(scale) - 1, 2)[0] = col
        out.ref(UInt(scale) - 1, 3)[0] = col
        out.ref(UInt(scale) - 1, 4)[0] = col
        out.ref(UInt(scale) - 2, 4)[0] = col
    }

    func blendLineShallow(_ col: UInt32, _ ref: (UInt, UInt) -> UnsafeMutablePointer<UInt32>) {
        alphaGrad(1, 4, ref(UInt(scale) - 1, 0), col)
        alphaGrad(1, 4, ref(UInt(scale) - 2, 2), col)
        alphaGrad(1, 4, ref(UInt(scale) - 3, 4), col)

        alphaGrad(3, 4, ref(UInt(scale) - 1, 1), col)
        alphaGrad(3, 4, ref(UInt(scale) - 2, 3), col)

        ref(UInt(scale) - 1, 2)[0] = col
        ref(UInt(scale) - 1, 3)[0] = col
        ref(UInt(scale) - 1, 4)[0] = col
        ref(UInt(scale) - 2, 4)[0] = col
    }

    func blendLineSteep(_ col: UInt32, _ out: inout OutputMatrix) {
        alphaGrad(1, 4, out.ref(0, UInt(scale) - 1), col)
        alphaGrad(1, 4, out.ref(2, UInt(scale) - 2), col)
        alphaGrad(1, 4, out.ref(4, UInt(scale) - 3), col)

        alphaGrad(3, 4, out.ref(1, UInt(scale) - 1), col)
        alphaGrad(3, 4, out.ref(3, UInt(scale) - 2), col)

        out.ref(2, UInt(scale) - 1)[0] = col
        out.ref(3, UInt(scale) - 1)[0] = col
        out.ref(4, UInt(scale) - 1)[0] = col
        out.ref(4, UInt(scale) - 2)[0] = col
    }

    func blendLineSteep(_ col: UInt32, _ ref: (UInt, UInt) -> UnsafeMutablePointer<UInt32>) {
        alphaGrad(1, 4, ref(0, UInt(scale) - 1), col)
        alphaGrad(1, 4, ref(2, UInt(scale) - 2), col)
        alphaGrad(1, 4, ref(4, UInt(scale) - 3), col)

        alphaGrad(3, 4, ref(1, UInt(scale) - 1), col)
        alphaGrad(3, 4, ref(3, UInt(scale) - 2), col)

        ref(2, UInt(scale) - 1)[0] = col
        ref(3, UInt(scale) - 1)[0] = col
        ref(4, UInt(scale) - 1)[0] = col
        ref(4, UInt(scale) - 2)[0] = col
    }

    func blendLineSteepAndShallow(_ col: UInt32, _ out: inout OutputMatrix) {
        alphaGrad(1, 4, out.ref(0, UInt(scale) - 1), col)
        alphaGrad(1, 4, out.ref(2, UInt(scale) - 2), col)
        alphaGrad(3, 4, out.ref(1, UInt(scale) - 1), col)

        alphaGrad(1, 4, out.ref(UInt(scale) - 1, 0), col)
        alphaGrad(1, 4, out.ref(UInt(scale) - 2, 2), col)
        alphaGrad(3, 4, out.ref(UInt(scale) - 1, 1), col)

        alphaGrad(2, 3, out.ref(3, 3), col)

        out.ref(2, UInt(scale) - 1)[0] = col
        out.ref(3, UInt(scale) - 1)[0] = col
        out.ref(4, UInt(scale) - 1)[0] = col

        out.ref(UInt(scale) - 1, 2)[0] = col
        out.ref(UInt(scale) - 1, 3)[0] = col
    }

    func blendLineSteepAndShallow(_ col: UInt32, _ ref: (UInt, UInt) -> UnsafeMutablePointer<UInt32>) {
        alphaGrad(1, 4, ref(0, UInt(scale) - 1), col)
        alphaGrad(1, 4, ref(2, UInt(scale) - 2), col)
        alphaGrad(3, 4, ref(1, UInt(scale) - 1), col)

        alphaGrad(1, 4, ref(UInt(scale) - 1, 0), col)
        alphaGrad(1, 4, ref(UInt(scale) - 2, 2), col)
        alphaGrad(3, 4, ref(UInt(scale) - 1, 1), col)

        alphaGrad(2, 3, ref(3, 3), col)

        ref(2, UInt(scale) - 1)[0] = col
        ref(3, UInt(scale) - 1)[0] = col
        ref(4, UInt(scale) - 1)[0] = col

        ref(UInt(scale) - 1, 2)[0] = col
        ref(UInt(scale) - 1, 3)[0] = col
    }

    func blendLineDiagonal(_ col: UInt32, _ out: inout OutputMatrix) {
        alphaGrad(1, 8, out.ref(UInt(scale) - 1, UInt(scale / 2)), col)
        alphaGrad(1, 8, out.ref(UInt(scale) - 2, UInt(scale / 2) + 1), col)
        alphaGrad(1, 8, out.ref(UInt(scale) - 3, UInt(scale / 2) + 2), col)

        alphaGrad(7, 8, out.ref(4, 3), col)
        alphaGrad(7, 8, out.ref(3, 4), col)

        out.ref(4, 4)[0] = col
    }

    func blendLineDiagonal(_ col: UInt32, _ ref: (UInt, UInt) -> UnsafeMutablePointer<UInt32>) {
        alphaGrad(1, 8, ref(UInt(scale) - 1, UInt(scale / 2)), col)
        alphaGrad(1, 8, ref(UInt(scale) - 2, UInt(scale / 2) + 1), col)
        alphaGrad(1, 8, ref(UInt(scale) - 3, UInt(scale / 2) + 2), col)

        alphaGrad(7, 8, ref(4, 3), col)
        alphaGrad(7, 8, ref(3, 4), col)

        ref(4, 4)[0] = col
    }

    func blendCorner(_ col: UInt32, _ out: inout OutputMatrix) {
        alphaGrad(86, 100, out.ref(4, 4), col)  //exact: 0.8631434088
        alphaGrad(23, 100, out.ref(4, 3), col)  //0.2306749731
        alphaGrad(23, 100, out.ref(3, 4), col)  //0.2306749731
    }

    func blendCorner(_ col: UInt32, _ ref: (UInt, UInt) -> UnsafeMutablePointer<UInt32>) {
        alphaGrad(86, 100, ref(4, 4), col)  //exact: 0.8631434088
        alphaGrad(23, 100, ref(4, 3), col)  //0.2306749731
        alphaGrad(23, 100, ref(3, 4), col)  //0.2306749731
    }
}
