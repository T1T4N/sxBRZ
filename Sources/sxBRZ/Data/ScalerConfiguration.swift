//
//  ScalerCfg.swift
//  sxBRZ
//
//  Created by T!T@N on 04.25.16.
//

import Foundation

public struct ScalerConfiguration {
    let luminanceWeight: Double
    let equalColorTolerance: Double
    let dominantDirectionThreshold: Double
    let steepDirectionThreshold: Double
    let newTestAttribute: Double //unused; test new parameters

    public init() {
        self.luminanceWeight = 1
        self.equalColorTolerance = 30
        self.dominantDirectionThreshold = 3.6
        self.steepDirectionThreshold = 2.2
        self.newTestAttribute = 0
    }
}
