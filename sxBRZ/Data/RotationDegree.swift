//
//  RotationDegree.swift
//  sxBRZ
//
//  Created by T!T@N on 04.22.16.
//

import Foundation

enum RotationDegree : Int, CustomStringConvertible {
    case rot_0 = 0
    case rot_90 = 1
    case rot_180 = 2
    case rot_270 = 3
    
    var description : String {
        switch self {
        case .rot_0: return "ROT_0";
        case .rot_90: return "ROT_90";
        case .rot_180: return "ROT_180";
        case .rot_270: return "ROT_270";
        }
    }
}
