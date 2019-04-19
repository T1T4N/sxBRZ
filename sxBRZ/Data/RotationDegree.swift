//
//  RotationDegree.swift
//  sxBRZ
//
//  Created by T!T@N on 04.22.16.
//

import Foundation

enum RotationDegree: Int {
    case zero = 0
    case rot90 = 1
    case rot180 = 2
    case rot270 = 3
}

extension RotationDegree: CustomStringConvertible {
    var description: String {
        switch self {
        case .zero: return "ROT_0"
        case .rot90: return "ROT_90"
        case .rot180: return "ROT_180"
        case .rot270: return "ROT_270"
        }
    }
}

extension RotationDegree {
    //template <RotationDegree rotDeg> uint32_t inline get_##x(const Kernel_3x3& ker) { return ker.x; }
    func getA(for ker: Kernel_3x3) -> UInt32 {
        switch self {
        case .zero:
            return ker.a
        case .rot90:
            return ker.g
        case .rot180:
            return ker.i
        case .rot270:
            return ker.c
        }
    }

    func getB(for ker: Kernel_3x3) -> UInt32 {
        switch self {
        case .zero:
            return ker.b
        case .rot90:
            return ker.d
        case .rot180:
            return ker.h
        case .rot270:
            return ker.f
        }
    }

    func getC(for ker: Kernel_3x3) -> UInt32 {
        switch self {
        case .zero:
            return ker.c
        case .rot90:
            return ker.a
        case .rot180:
            return ker.g
        case .rot270:
            return ker.i
        }
    }

    func getD(for ker: Kernel_3x3) -> UInt32 {
        switch self {
        case .zero:
            return ker.d
        case .rot90:
            return ker.h
        case .rot180:
            return ker.f
        case .rot270:
            return ker.b
        }
    }

    func getE(for ker: Kernel_3x3) -> UInt32 { return ker.e }

    func getF(for ker: Kernel_3x3) -> UInt32 {
        switch self {
        case .zero:
            return ker.f
        case .rot90:
            return ker.b
        case .rot180:
            return ker.d
        case .rot270:
            return ker.h
        }
    }

    func getG(for ker: Kernel_3x3) -> UInt32 {
        switch self {
        case .zero:
            return ker.g
        case .rot90:
            return ker.i
        case .rot180:
            return ker.c
        case .rot270:
            return ker.a
        }
    }

    func getH(for ker: Kernel_3x3) -> UInt32 {
        switch self {
        case .zero:
            return ker.h
        case .rot90:
            return ker.f
        case .rot180:
            return ker.b
        case .rot270:
            return ker.d
        }
    }

    func getI(for ker: Kernel_3x3) -> UInt32 {
        switch self {
        case .zero:
            return ker.i
        case .rot90:
            return ker.c
        case .rot180:
            return ker.a
        case .rot270:
            return ker.g
        }
    }
    
}
