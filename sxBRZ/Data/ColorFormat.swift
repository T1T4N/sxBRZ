//
//  ColorFormat.swift
//  sxBRZ
//
//  Created by T!T@N on 04.22.16.
//

import Foundation

enum ColorFormat {
    case rgb
    case argb
}

extension ColorFormat {
    var gradient: ColorGradient {
        switch self {
        case .rgb:
            return ColorGradientRGB.instance
        case .argb:
            return ColorGradientARGB.instance
        }
    }
}

extension ColorFormat {
    var distance: ColorDistance {
        switch self {
        case .rgb:
            return ColorDistanceRGB.instance
        case .argb:
            return ColorDistanceARGB.instance
        }
    }
}
