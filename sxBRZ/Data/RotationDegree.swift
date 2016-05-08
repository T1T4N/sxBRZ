//
//  RotationDegree.swift
//  sxBRZ
//
//  Created by T!T@N on 04.22.16.
//

import Foundation

enum RotationDegree : Int, CustomStringConvertible {
    case ROT_0 = 0
    case ROT_90 = 1
    case ROT_180 = 2
    case ROT_270 = 3
    
    var description : String {
        switch self {
        case .ROT_0: return "ROT_0";
        case .ROT_90: return "ROT_90";
        case .ROT_180: return "ROT_180";
        case .ROT_270: return "ROT_270";
        }
    }
}
