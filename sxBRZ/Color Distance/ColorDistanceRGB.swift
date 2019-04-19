//
//  ColorDistanceRGB.swift
//  sxBRZ
//
// Created by T!T@N on 04.26.16.
//

import Foundation

struct ColorDistanceRGB: ColorDistance {
    static let instance: ColorDistance = ColorDistanceRGB()

    func dist(_ pix1: UInt32, _ pix2: UInt32, _ luminanceWeight: Double) -> Double {
        return DistYCbCrBuffer.dist(pix1, pix2)
//        if (pix1 == pix2) //about 4% perf boost
//        {
//            return 0.0;
//        }
//        return distYCbCr(pix1, pix2, luminanceWeight);
    }
}
