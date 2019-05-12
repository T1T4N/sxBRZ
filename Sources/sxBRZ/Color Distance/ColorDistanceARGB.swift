//
//  ColorDistanceARGB.swift
//  sxBRZ
//
// Created by T!T@N on 04.26.16.
//

import Foundation

class ColorDistanceARGB: ColorDistance {
    static let instance: ColorDistance = ColorDistanceARGB()

    func dist(_ pix1: RawPixel, _ pix2: RawPixel, _ luminanceWeight: Double) -> Double {
        let alpha1 = Double(pix1.alpha) / 255.0
        let alpha2 = Double(pix2.alpha) / 255.0
        /*
         Requirements for a color distance handling alpha channel: with a1, a2 in [0, 1]

         1. if a1 = a2, distance should be: a1 * distYCbCr()
         2. if a1 = 0,  distance should be: a2 * distYCbCr(black, white) = a2 * 255
         3. if a1 = 1,  ??? maybe: 255 * (1 - a2) + a2 * distYCbCr()
         */

        //return std::min(a1, a2) * DistYCbCrBuffer::dist(pix1, pix2) + 255 * abs(a1 - a2);
        //=> following code is 15% faster:
        let dist = DistYCbCrBuffer.instance.dist(pix1, pix2)
        // let dist = distYCbCr(pix1, pix2, 1.0)
        if alpha1 < alpha2 {
            return alpha1 * dist + 255 * (alpha2 - alpha1)
        } else {
            return alpha2 * dist + 255 * (alpha1 - alpha2)
        }
        //alternative? return std::sqrt(a1 * a2 * square(DistYCbCrBuffer::dist(pix1, pix2)) + square(255 * (a1 - a2)));
    }
}
