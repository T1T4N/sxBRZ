//
//  DistYCbCrBuffer.swift
//  sxBRZ
//
//  Created by T!T@N on 04.25.16.
//

import Foundation

// swiftlint:disable identifier_name
func distYCbCr(_ pix1: RawPixel, _ pix2: RawPixel,
               _ lumaWeight: Double = 1.0) -> Double {
    //http://en.wikipedia.org/wiki/YCbCr#ITU-R_BT.601_conversion
    //YCbCr conversion is a matrix multiplication => take advantage of linearity by subtracting first!
    let rDiff = Int(pix1.red) - Int(pix2.red) //we may delay division by 255 to after matrix multiplication
    let gDiff = Int(pix1.green) - Int(pix2.green) //
    let bDiff = Int(pix1.blue) - Int(pix2.blue) //substraction for int is noticeable faster than for double!

    //const double coefB = 0.0722; //ITU-R BT.709 conversion
    //const double coefR = 0.2126; //
    let coefB: Double = 0.0593 //ITU-R BT.2020 conversion
    let coefR: Double = 0.2627 //
    let coefG: Double = 1 - coefB - coefR

    let scaleB: Double = 0.5 / (1 - coefB)
    let scaleR: Double = 0.5 / (1 - coefR)

    let y: Double =
        coefR * Double(rDiff) +
        coefG * Double(gDiff) +
        coefB * Double(bDiff) //[!], analog YCbCr!
    let c_b: Double = scaleB * (Double(bDiff) - y)
    let c_r: Double = scaleR * (Double(rDiff) - y)

    //we skip division by 255 to have similar range like other distance functions
    return sqrt(
        pow(lumaWeight * y, 2) +
        pow(c_b, 2) +
        pow(c_r, 2)
    )
}

struct DistYCbCrBuffer {
    var buffer: [Float] = .init(repeating: 0.0, count: 256*256*256)
    fileprivate init() {
        //startup time: 114 ms on Intel Core i5 (four cores)
        for i: RawPixel in 0 ..< 256 * 256 * 256 {
            let rDiff = Int(i.red) * 2 - 255
            let gDiff = Int(i.green) * 2 - 255
            let bDiff = Int(i.blue) * 2 - 255

            let k_b: Double = 0.0593 //ITU-R BT.2020 conversion
            let k_r: Double = 0.2627 //
            let k_g: Double = 1 - k_b - k_r

            let scale_b: Double = 0.5 / (1 - k_b)
            let scale_r: Double = 0.5 / (1 - k_r)

            let y: Double =
                k_r * Double(rDiff) +
                k_g * Double(gDiff) +
                k_b * Double(bDiff) //[!], analog YCbCr!

            let c_b: Double = scale_b * (Double(bDiff) - y)
            let c_r: Double = scale_r * (Double(rDiff) - y)

            buffer[Int(i)] = Float(sqrt(pow(y, 2) + pow(c_b, 2) + pow(c_r, 2)))
        }
    }

    static let instance = DistYCbCrBuffer()
}

extension DistYCbCrBuffer {
    func dist(_ pix1: RawPixel, _ pix2: RawPixel) -> Double {
        //if (pix1 == pix2) -> 8% perf degradation!
        //    return 0;
        //if (pix1 > pix2)
        //      std::swap(pix1, pix2); -> 30% perf degradation!!!

        let rDiff = Int(pix1.red) - Int(pix2.red)
        let gDiff = Int(pix1.green) - Int(pix2.green)
        let bDiff = Int(pix1.blue) - Int(pix2.blue)
        let buffIdx =
            (((rDiff + 255) / 2) << 16) |
            (((gDiff + 255) / 2) <<  8) |
            (( bDiff + 255) / 2)

        return Double(buffer[buffIdx])
    }
}
