//
//  OutputMatrix.swift
//  sxBRZ
//
//  Created by T!T@N on 04.24.16.
//

import Foundation

// swiftlint:disable identifier_name
class OutputMatrix {
    let N: UInt
    let rotDeg: RotationDegree
    let out: UnsafeMutablePointer<RawPixel>
    let outWidth: Int

    init(_ N: UInt, _ rotDeg: RotationDegree,
         _ out: UnsafeMutablePointer<RawPixel>, _ outWidth: Int ) {
        self.N = N
        self.rotDeg = rotDeg
        self.out = out
        self.outWidth = outWidth
    }

    init(_ N: UInt, _ rotDeg: RotationDegree,
         out: inout [RawPixel], _ currentOffset: Int, _ outWidth: Int ) {
        self.N = N
        self.rotDeg = rotDeg
        self.out = UnsafeMutablePointer(&out) + currentOffset
        self.outWidth = outWidth
    }

    func ref(_ I: UInt, _ J: UInt) -> UnsafeMutablePointer<RawPixel> {
        let I_old = MatrixRotation.instance(rotDeg, I, J, N).oldI
        let J_old = MatrixRotation.instance(rotDeg, I, J, N).oldJ
        return (out + Int(J_old) + Int(I_old) * outWidth)
    }

    static func ref(_ N: UInt, _ rotDeg: RotationDegree,
                    _ target: UnsafeMutablePointer<RawPixel>,
                    _ currentOffset: Int,
                    _ outWidth: Int)
        -> (UInt, UInt) -> UnsafeMutablePointer<RawPixel> {
            func refx(_ I: UInt, _ J: UInt) -> UnsafeMutablePointer<RawPixel> {
                let I_old = MatrixRotation.instance(rotDeg, I, J, N).oldI
                let J_old = MatrixRotation.instance(rotDeg, I, J, N).oldJ
                return target + currentOffset + Int(J_old) + Int(I_old) * outWidth
            }
            return refx
    }

    static func ref(_ N: UInt, _ rotDeg: RotationDegree,
                    _ target: UnsafeMutablePointer<RawPixel>,
                    _ outWidth: Int)
        -> (UInt, UInt) -> UnsafeMutablePointer<RawPixel> {
            func refx(_ I: UInt, _ J: UInt) -> UnsafeMutablePointer<RawPixel> {
                let I_old = MatrixRotation.instance(rotDeg, I, J, N).oldI
                let J_old = MatrixRotation.instance(rotDeg, I, J, N).oldJ
                return target + Int(J_old) + (Int(I_old) * outWidth)
            }
            return refx
    }

}
