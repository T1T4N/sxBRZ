//
//  BlendType.swift
//  sxBRZ
//
//  Created by T!T@N on 04.25.16.
//

import Foundation

enum BlendType: UInt8
{
    case BLEND_NONE = 0
    case BLEND_NORMAL   //a normal indication to blend
    case BLEND_DOMINANT //a strong indication to blend
     case BLEND_UNDEFINED
    //attention: BlendType must fit into the value range of 2 bit!!!
}
