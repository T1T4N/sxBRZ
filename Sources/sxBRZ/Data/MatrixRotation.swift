//
//  MatrixRotation.swift
//  sxBRZ
//
//  Created by T!T@N on 04.22.16.
//

import Foundation

// swiftlint:disable identifier_name
struct MatrixRotation {
    let oldI: UInt
    let oldJ: UInt

    fileprivate init(_ rotDeg: RotationDegree,
                     _ I: UInt, _ J: UInt, _ N: UInt) {
        if rotDeg == RotationDegree.zero {
            self.oldI = I
            self.oldJ = J
        } else {
            let oldRot = RotationDegree(rawValue: rotDeg.rawValue - 1)!
            let matRot = MatrixRotation.instance(oldRot, I, J, N)
            self.oldI = N - 1 - matRot.oldJ
            self.oldJ =         matRot.oldI
        }
    }

    private static let instance = cache { (key: TupleKey) in
        return MatrixRotation(key.rotDeg, key.I, key.J, key.N)
    }

    public static func instance(_ rotDeg: RotationDegree,
                                _ I: UInt, _ J: UInt, _ N: UInt) -> MatrixRotation {
        let tk = TupleKey(rotDeg: rotDeg, I: I, J: J, N: N)
        return instance(tk)
    }
}

private struct TupleKey: Equatable {
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
