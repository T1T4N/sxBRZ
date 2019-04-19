//
//  ColorDistance.swift
//  sxBRZ
//
//  Created by T!T@N on 04.25.16.
//

import Foundation

protocol ColorDistance {
    static var instance: ColorDistance { get }

    func dist(_ pix1: RawPixel, _ pix2: RawPixel, _ luminanceWeight: Double) -> Double
}
