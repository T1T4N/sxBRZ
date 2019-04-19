//
//  ColorDistanceARGB.swift
//  sxBRZ
//
// Created by T!T@N on 04.26.16.
//

import Foundation

struct ColorDistanceARGB: ColorDistance {
    static let instance: ColorDistance = ColorDistanceARGB()

    func dist(_ pix1: UInt32, _ pix2: UInt32, _ luminanceWeight: Double) -> Double {
        let a1 = Double(getAlpha(pix1)) / 255.0
        let a2 = Double(getAlpha(pix2)) / 255.0
        /*
         Requirements for a color distance handling alpha channel: with a1, a2 in [0, 1]

         1. if a1 = a2, distance should be: a1 * distYCbCr()
         2. if a1 = 0,  distance should be: a2 * distYCbCr(black, white) = a2 * 255
         3. if a1 = 1,  ??? maybe: 255 * (1 - a2) + a2 * distYCbCr()
         */

        //return std::min(a1, a2) * DistYCbCrBuffer::dist(pix1, pix2) + 255 * abs(a1 - a2);
        //=> following code is 15% faster:
        let dist = DistYCbCrBuffer.dist(pix1, pix2)
        // let dist = distYCbCr(pix1, pix2, 1.0)
        if a1 < a2 {
            return a1 * dist + 255 * (a2 - a1)
        } else {
            return a2 * dist + 255 * (a1 - a2)
        }
        //alternative? return std::sqrt(a1 * a2 * square(DistYCbCrBuffer::dist(pix1, pix2)) + square(255 * (a1 - a2)));
    }
}
