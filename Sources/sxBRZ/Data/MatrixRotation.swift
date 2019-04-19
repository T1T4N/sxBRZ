//
//  MatrixRotation.swift
//  sxBRZ
//
//  Created by T!T@N on 04.22.16.
//

import Foundation

// swiftlint:disable identifier_name
struct MatrixRotation {
    let I_old: UInt
    let J_old: UInt
    fileprivate static var Instances = [TupleKey:MatrixRotation]();

    fileprivate init(_ rotDeg: RotationDegree, _ I: UInt, _ J: UInt, _ N: UInt) {
        if rotDeg == RotationDegree.zero {
            self.I_old = I
            self.J_old = J
        } else {
            let oldRot = RotationDegree(rawValue: rotDeg.rawValue - 1)!
            let matRot = MatrixRotation.getInstance(oldRot, I, J, N)
            self.I_old = N - 1 - matRot.J_old
            self.J_old =         matRot.I_old
        }
    }

    static func getInstance(_ rotDeg: RotationDegree, _ I: UInt, _ J: UInt, _ N: UInt) -> MatrixRotation {
        let tk = TupleKey(rotDeg: rotDeg, I: I, J: J, N: N)
        if let instance = MatrixRotation.Instances[tk] {
            return instance
        } else {
            let newInstance = MatrixRotation(rotDeg, I, J, N)
            MatrixRotation.Instances[tk] = newInstance
            return newInstance
        }
    }
}

struct TupleKey: Equatable {
    let rotDeg: RotationDegree
    let I: UInt
    let J: UInt
    let N: UInt
}

extension TupleKey: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.rotDeg.rawValue)
        hasher.combine(self.I)
        hasher.combine(self.J)
        hasher.combine(self.N)
    }
}
