//
//  Scaler3x.swift
//  sxBRZ
//
// Created by T!T@N on 04.26.16.
//

import Foundation

// swiftlint:disable identifier_name
struct Scaler3x<T: ColorGradient>: Scaler {
    static var scale: Int { return 3 }

    static func alphaGrad(_ M: UInt32, _ N:UInt32, _ pixBack: UnsafeMutablePointer<UInt32>, _ pixFront: UInt32) {
        let pb = UnsafeMutablePointer<UInt32>(pixBack)
        T.instance.alphaGrad(M, N, &pb[0], pixFront)
        // T.instance.alphaGrad(M, N, pixBack: pixBack, pixFront)
    }
    static func alphaGrad(_ M: UInt32, _ N:UInt32,
                          _ pixBack: UInt32, _ pixFront: UInt32) -> UInt32 {
        return T.instance.alphaGrad(M, N, pixBack, pixFront)
    }

    static func blendLineShallow(_ col: UInt32, _ out: inout OutputMatrix) {
        alphaGrad(1, 4, out.ref(UInt(scale) - 1, 0), col)
        alphaGrad(1, 4, out.ref(UInt(scale) - 2, 2), col)
        alphaGrad(3, 4, out.ref(UInt(scale) - 1, 1), col)
        out.ref(UInt(scale)-1, 2)[0] = col
    }
    static func blendLineShallow(_ col: UInt32, _ ref: (UInt, UInt) -> UnsafeMutablePointer<UInt32>) {
        alphaGrad(1, 4, ref(UInt(scale) - 1, 0), col)
        alphaGrad(1, 4, ref(UInt(scale) - 2, 2), col)
        alphaGrad(3, 4, ref(UInt(scale) - 1, 1), col)
        ref(UInt(scale)-1, 2)[0] = col
    }

    static func blendLineSteep(_ col: UInt32, _ out: inout OutputMatrix) {
        alphaGrad(1, 4, out.ref(0, UInt(scale) - 1), col)
        alphaGrad(1, 4, out.ref(2, UInt(scale) - 2), col)
        alphaGrad(3, 4, out.ref(1, UInt(scale) - 1), col)
        out.ref(2, UInt(scale)-1)[0] = col
    }
    static func blendLineSteep(_ col: UInt32, _ ref: (UInt, UInt) -> UnsafeMutablePointer<UInt32>) {
        alphaGrad(1, 4, ref(0, UInt(scale) - 1), col)
        alphaGrad(1, 4, ref(2, UInt(scale) - 2), col)
        alphaGrad(3, 4, ref(1, UInt(scale) - 1), col)
        ref(2, UInt(scale)-1)[0] = col
    }

    static func blendLineSteepAndShallow(_ col: UInt32, _ out:inout OutputMatrix) {
        alphaGrad(1, 4, out.ref(2, 0), col)
        alphaGrad(1, 4, out.ref(0, 2), col)
        alphaGrad(3, 4, out.ref(2, 1), col)
        alphaGrad(3, 4, out.ref(1, 2), col)
        out.ref(2, 2)[0] = col
    }

    static func blendLineSteepAndShallow(_ col: UInt32, _ ref: (UInt, UInt) -> UnsafeMutablePointer<UInt32>) {
        alphaGrad(1, 4, ref(2, 0), col)
        alphaGrad(1, 4, ref(0, 2), col)
        alphaGrad(3, 4, ref(2, 1), col)
        alphaGrad(3, 4, ref(1, 2), col)
        ref(2, 2)[0] = col
    }

    static func blendLineDiagonal(_ col: UInt32, _ out: inout OutputMatrix) {
        alphaGrad(1, 8, out.ref(1, 2), col)
        alphaGrad(1, 8, out.ref(2, 1), col)
        alphaGrad(7, 8, out.ref(2, 2), col)
    }

    static func blendLineDiagonal(_ col: UInt32, _ ref: (UInt, UInt) -> UnsafeMutablePointer<UInt32>) {
        alphaGrad(1, 8, ref(1, 2), col)
        alphaGrad(1, 8, ref(2, 1), col)
        alphaGrad(7, 8, ref(2, 2), col)
    }

    static func blendCorner(_ col: UInt32, _ out: inout OutputMatrix) {
        alphaGrad(45, 100, out.ref(2, 2), col)    //exact: 0.4545939598
    }

    static func blendCorner(_ col: UInt32, _ ref: (UInt, UInt) -> UnsafeMutablePointer<UInt32>) {
        alphaGrad(45, 100, ref(2, 2), col)    //exact: 0.4545939598
    }
}
