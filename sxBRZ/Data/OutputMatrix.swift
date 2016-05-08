//
//  OutputMatrix.swift
//  sxBRZ
//
//  Created by T!T@N on 04.24.16.
//

import Foundation

class OutputMatrix {
    let N:UInt
    let rotDeg:RotationDegree
    let out:UnsafeMutablePointer<UInt32>
    let outWidth: Int
    
    init(_ N: UInt, _ rotDeg: RotationDegree, inout _ out: UnsafeMutablePointer<UInt32>, _ outWidth: Int ) {
        self.N = N
        self.rotDeg = rotDeg
        self.out = out
        self.outWidth = outWidth
    }
    init(_ N: UInt, _ rotDeg: RotationDegree, inout out: [UInt32], _ currentOffset: Int, _ outWidth: Int ) {
        self.N = N
        self.rotDeg = rotDeg
        self.out = UnsafeMutablePointer<UInt32>(out) + currentOffset
        self.outWidth = outWidth
    }
    func ref(I:UInt, _ J:UInt) -> UnsafeMutablePointer<UInt32> {
        let I_old = MatrixRotation.getInstance(rotDeg, I, J, N).I_old
        let J_old = MatrixRotation.getInstance(rotDeg, I, J, N).J_old
//        return UnsafeMutablePointer<UInt32>(out) + Int(J_old) + Int(I_old) * outWidth
        return (out + Int(J_old) + Int(I_old) * outWidth)
    }
    
    static func ref(N:UInt, _ rotDeg: RotationDegree, inout _ target: [UInt32], _ currentOffset: Int, _ outWidth:Int) -> (UInt, UInt) -> UnsafeMutablePointer<UInt32> {
        func refx(I:UInt, _ J:UInt) -> UnsafeMutablePointer<UInt32> {
            let I_old = MatrixRotation.getInstance(rotDeg, I, J, N).I_old
            let J_old = MatrixRotation.getInstance(rotDeg, I, J, N).J_old
            return UnsafeMutablePointer<UInt32>(target) + currentOffset + Int(J_old) + Int(I_old) * outWidth
        }
        return refx
    }
    static func ref(N:UInt, _ rotDeg: RotationDegree, inout _ target: UnsafeMutablePointer<UInt32>, _ outWidth:Int) -> (UInt, UInt) -> UnsafeMutablePointer<UInt32> {
        func refx(I:UInt, _ J:UInt) -> UnsafeMutablePointer<UInt32> {
            let I_old = MatrixRotation.getInstance(rotDeg, I, J, N).I_old
            let J_old = MatrixRotation.getInstance(rotDeg, I, J, N).J_old
            return UnsafeMutablePointer<UInt32>(target) + Int(J_old) + (Int(I_old) * outWidth)
        }
        return refx
    }
}