//
//  Scaler2x.swift
//  sxBRZ
//
// Created by T!T@N on 04.26.16.
//

import Foundation

struct Scaler2x: Scaler {
    let gradient: ColorGradient
    var scale: Int { return 2 }

    func alphaGrad(_ M: UInt32, _ N: UInt32,
                   _ pixBack: UnsafeMutablePointer<UInt32>, _ pixFront: UInt32) {
        let pb = UnsafeMutablePointer<UInt32>(pixBack)
        gradient.alphaGrad(M, N, &pb[0], pixFront)
    }

    func blendLineShallow(_ col: UInt32, _ out: inout OutputMatrix) {
        alphaGrad(1, 4, out.ref(UInt(scale) - 1, 0), col)
        alphaGrad(3, 4, out.ref(UInt(scale) - 1, 1), col)
    }

    func blendLineShallow(_ col: UInt32, _ ref: (UInt, UInt) -> UnsafeMutablePointer<UInt32>) {
        alphaGrad(1, 4, ref(UInt(scale) - 1, 0), col)
        alphaGrad(3, 4, ref(UInt(scale) - 1, 1), col)
    }

    func blendLineSteep(_ col: UInt32, _ out: inout OutputMatrix) {
        alphaGrad(1, 4, out.ref(0, UInt(scale) - 1), col)
        alphaGrad(3, 4, out.ref(1, UInt(scale) - 1), col)
    }

    func blendLineSteep(_ col: UInt32, _ ref: (UInt, UInt) -> UnsafeMutablePointer<UInt32>) {
        alphaGrad(1, 4, ref(0, UInt(scale) - 1), col)
        alphaGrad(3, 4, ref(1, UInt(scale) - 1), col)
    }

    func blendLineSteepAndShallow(_ col: UInt32, _ out: inout OutputMatrix) {
        alphaGrad(1, 4, out.ref(1, 0), col)
        alphaGrad(1, 4, out.ref(0, 1), col)
        alphaGrad(5, 6, out.ref(1, 1), col)
    }

    func blendLineSteepAndShallow(_ col: UInt32, _ ref: (UInt, UInt) -> UnsafeMutablePointer<UInt32>) {
        alphaGrad(1, 4, ref(1, 0), col)
        alphaGrad(1, 4, ref(0, 1), col)
        alphaGrad(5, 6, ref(1, 1), col)
    }

    func blendLineDiagonal(_ col: UInt32, _ out: inout OutputMatrix) {
        alphaGrad(1, 2, out.ref(1, 1), col)
    }

    func blendLineDiagonal(_ col: UInt32, _ ref: (UInt, UInt) -> UnsafeMutablePointer<UInt32>) {
        alphaGrad(1, 2, ref(1, 1), col)
    }

    func blendCorner(_ col: UInt32, _ out: inout OutputMatrix) {
        alphaGrad(21, 100, out.ref(1, 1), col)
    }

    func blendCorner(_ col: UInt32, _ ref: (UInt, UInt) -> UnsafeMutablePointer<UInt32>) {
        alphaGrad(21, 100, ref(1, 1), col)
    }
}
