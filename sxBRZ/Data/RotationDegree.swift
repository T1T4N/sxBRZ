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
