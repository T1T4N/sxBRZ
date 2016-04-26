//
//  MatrixRotation.swift
//  sxBRZ
//
//  Created by T!T@N on 04.22.16.
//

import Foundation

struct MatrixRotation {
    let I_old:UInt
    let J_old:UInt
    private static var Instances = [TupleKey:MatrixRotation]();

    private init(_ rotDeg: RotationDegree, _ I: UInt, _ J: UInt, _ N: UInt) {
        if rotDeg == RotationDegree.ROT_0 {
            self.I_old = I
            self.J_old = J
        } else {
            let oldRot = RotationDegree(rawValue: rotDeg.rawValue - 1)!
            let matRot = MatrixRotation.getInstance(oldRot, I, J, N)
            self.I_old = N - 1 - matRot.I_old
            self.J_old =         matRot.J_old
        }
    }

    private init(I: UInt, _ J: UInt, _ N: UInt) {
        self.init(RotationDegree.ROT_0, I, J, N)
    }
    static func getInstance(rotDeg: RotationDegree, _ I: UInt, _ J: UInt, _ N: UInt) -> MatrixRotation {
        let tk = TupleKey(rotDeg, I, J, N)
        if let instance = MatrixRotation.Instances[tk] {
            return instance
        } else {
            let newInstance = MatrixRotation(rotDeg, I, J, N)
            MatrixRotation.Instances[tk] = newInstance
            return newInstance
        }
    }
}

struct TupleKey : Hashable {
    let rotDeg: RotationDegree
    let I: UInt
    let J: UInt
    let N: UInt
    init( _ rotDeg: RotationDegree, _ I: UInt, _ J: UInt, _ N: UInt) {
        self.rotDeg = rotDeg
        self.I = I
        self.J = J
        self.N = N
    }
    var hashValue: Int {
        return self.rotDeg.rawValue * Int(2*self.I) * Int(3*self.J) * Int(4*self.N)
    }
}

func ==(lhs: TupleKey, rhs: TupleKey) -> Bool {
    return lhs.rotDeg == rhs.rotDeg &&
            lhs.I == rhs.I &&
            lhs.J == rhs.J &&
            lhs.N == rhs.N
}