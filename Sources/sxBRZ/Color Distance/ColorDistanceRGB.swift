//
//  ColorDistanceRGB.swift
//  sxBRZ
//
// Created by T!T@N on 04.26.16.
//

import Foundation

class ColorDistanceRGB: ColorDistance {
    static let instance: ColorDistance = ColorDistanceRGB()

    func dist(_ pix1: RawPixel, _ pix2: RawPixel, _ luminanceWeight: Double) -> Double {
        return DistYCbCrBuffer.instance.dist(pix1, pix2)
//        if (pix1 == pix2) //about 4% perf boost
//        {
//            return 0.0;
//        }
//        return distYCbCr(pix1, pix2, luminanceWeight);
    }
}
