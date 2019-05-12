//
//  Kernel3.swift
//  sxBRZ
//
//  Created by Robert Armenski on 19.04.19.
//  Copyright © 2019 TitanTech. All rights reserved.
//

import Foundation

// swiftlint:disable identifier_name
struct Kernel3x3 {
    let
    a: UInt32, b: UInt32, c: UInt32,
    d: UInt32, e: UInt32, f: UInt32,
    g: UInt32, h: UInt32, i: UInt32
}

extension Kernel3x3: CustomStringConvertible {
    var description: String {
        return String(format: "%d %d %d %d %d %d %d %d %d",
                      self.a, self.b, self.c,
                      self.d, self.e, self.f,
                      self.g, self.h, self.i)
    }
}

extension Kernel3x3 {
    //template <RotationDegree rotDeg> uint32_t inline get_##x(const Kernel_3x3& ker) { return ker.x; }
    func getA(_ rotation: RotationDegree = .zero) -> UInt32 {
        switch rotation {
        case .zero:
            return self.a
        case .rot90:
            return self.g
        case .rot180:
            return self.i
        case .rot270:
            return self.c
        }
    }

    func getB(_ rotation: RotationDegree = .zero) -> UInt32 {
        switch rotation {
        case .zero:
            return self.b
        case .rot90:
            return self.d
        case .rot180:
            return self.h
        case .rot270:
            return self.f
        }
    }

    func getC(_ rotation: RotationDegree = .zero) -> UInt32 {
        switch rotation {
        case .zero:
            return self.c
        case .rot90:
            return self.a
        case .rot180:
            return self.g
        case .rot270:
            return self.i
        }
    }

    func getD(_ rotation: RotationDegree = .zero) -> UInt32 {
        switch rotation {
        case .zero:
            return self.d
        case .rot90:
            return self.h
        case .rot180:
            return self.f
        case .rot270:
            return self.b
        }
    }

    func getE(_ rotation: RotationDegree = .zero) -> UInt32 {
        return self.e
    }

    func getF(_ rotation: RotationDegree = .zero) -> UInt32 {
        switch rotation {
        case .zero:
            return self.f
        case .rot90:
            return self.b
        case .rot180:
            return self.d
        case .rot270:
            return self.h
        }
    }

    func getG(_ rotation: RotationDegree = .zero) -> UInt32 {
        switch rotation {
        case .zero:
            return self.g
        case .rot90:
            return self.i
        case .rot180:
            return self.c
        case .rot270:
            return self.a
        }
    }

    func getH(_ rotation: RotationDegree = .zero) -> UInt32 {
        switch rotation {
        case .zero:
            return self.h
        case .rot90:
            return self.f
        case .rot180:
            return self.b
        case .rot270:
            return self.d
        }
    }

    func getI(_ rotation: RotationDegree = .zero) -> UInt32 {
        switch rotation {
        case .zero:
            return self.i
        case .rot90:
            return self.c
        case .rot180:
            return self.a
        case .rot270:
            return self.g
        }
    }

}
