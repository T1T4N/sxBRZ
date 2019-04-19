//
//  ColorDistance.swift
//  sxBRZ
//
//  Created by T!T@N on 04.25.16.
//

import Foundation

protocol ColorDistance {
    static var instance: ColorDistance { get }

    func dist(_ pix1: UInt32, _ pix2: UInt32, _ luminanceWeight: Double) -> Double
}
