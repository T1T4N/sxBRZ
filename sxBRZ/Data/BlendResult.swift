//
//  BlendResult.swift
//  sxBRZ
//
//  Created by T!T@N on 04.25.16.
//

import Foundation

struct BlendResult: CustomStringConvertible {
    var
    /**/blend_f:BlendType = BlendType.none, blend_g:BlendType = BlendType.none,
    /**/blend_j:BlendType = BlendType.none, blend_k:BlendType = BlendType.none
    
    var description: String {
        get {
            return String(format: "%d %d %d %d", self.blend_f.rawValue, self.blend_g.rawValue, self.blend_j.rawValue, self.blend_k.rawValue)
        }
    }
};
