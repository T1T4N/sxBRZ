//
//  BlendResult.swift
//  sxBRZ
//
//  Created by T!T@N on 04.25.16.
//

import Foundation

struct BlendResult {
    var blendF: BlendType = .none
    var blendG: BlendType = .none
    var blendJ: BlendType = .none
    var blendK: BlendType = .none
}

extension BlendResult: CustomStringConvertible {
    var description: String {
        return String(format: "%d %d %d %d",
                      self.blendF.rawValue,
                      self.blendG.rawValue,
                      self.blendJ.rawValue,
                      self.blendK.rawValue)
    }
}
