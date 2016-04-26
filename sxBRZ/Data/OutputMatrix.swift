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
    
    init(_ N: UInt, _ rotDeg: RotationDegree, _ out: UnsafeMutablePointer<UInt32>, _ outWidth: Int ) {
        self.N = N
        self.rotDeg = rotDeg
        self.out = UnsafeMutablePointer<UInt32>(out)
        self.outWidth = outWidth
    }
    func ref(I:UInt, _ J:UInt) -> UnsafeMutablePointer<UInt32> {
        let I_old = MatrixRotation.getInstance(rotDeg, I, J, N).I_old
        let J_old = MatrixRotation.getInstance(rotDeg, I, J, N).J_old
//        return UnsafeMutablePointer<UInt32>(out[Int(J_old) + Int(I_old) * outWidth])
        return UnsafeMutablePointer<UInt32>(out + Int(J_old) + Int(I_old) * outWidth)
    }
    
}