//
//  BlendType.swift
//  sxBRZ
//
//  Created by T!T@N on 04.25.16.
//

import Foundation

enum BlendType: UInt8
{
    case none = 0
    case normal = 1   //a normal indication to blend
    case dominant = 2 //a strong indication to blend
    //case undefined
    //attention: BlendType must fit into the value range of 2 bit!!!
}
