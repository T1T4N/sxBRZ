//
//  DistYCbCrBuffer.swift
//  sxBRZ
//
//  Created by T!T@N on 04.25.16.
//

import Foundation

func distYCbCr(_ pix1: RawPixel, _ pix2: RawPixel, _ lumaWeight: Double = 1.0) -> Double
{
    //http://en.wikipedia.org/wiki/YCbCr#ITU-R_BT.601_conversion
    //YCbCr conversion is a matrix multiplication => take advantage of linearity by subtracting first!
    let r_diff = Int(pix1.red) - Int(pix2.red) //we may delay division by 255 to after matrix multiplication
    let g_diff = Int(pix1.green) - Int(pix2.green) //
    let b_diff = Int(pix1.blue) - Int(pix2.blue) //substraction for int is noticeable faster than for double!

    //const double k_b = 0.0722; //ITU-R BT.709 conversion
    //const double k_r = 0.2126; //
    let k_b:Double = 0.0593 //ITU-R BT.2020 conversion
    let k_r:Double = 0.2627 //
    let k_g:Double = 1 - k_b - k_r

    let scale_b:Double = 0.5 / (1 - k_b)
    let scale_r:Double = 0.5 / (1 - k_r)

    let y:Double = k_r * Double(r_diff) + k_g * Double(g_diff) + k_b * Double(b_diff) //[!], analog YCbCr!
    let c_b: Double = scale_b * (Double(b_diff) - y)
    let c_r: Double = scale_r * (Double(r_diff) - y)

    //we skip division by 255 to have similar range like other distance functions
    return sqrt(pow(lumaWeight * y,2) + pow(c_b,2) + pow(c_r,2))
}

struct DistYCbCrBuffer {
    var buffer: [Float]
    fileprivate init() {
        buffer = [Float](repeating: 0.0, count: 256*256*256)
        for i: RawPixel in 0 ..< 256 * 256 * 256 //startup time: 114 ms on Intel Core i5 (four cores)
        {
            let r_diff = Int(i.red) * 2 - 255
            let g_diff = Int(i.green) * 2 - 255
            let b_diff = Int(i.blue) * 2 - 255
            
            let k_b:Double = 0.0593 //ITU-R BT.2020 conversion
            let k_r:Double = 0.2627 //
            let k_g:Double = 1 - k_b - k_r

            let scale_b:Double = 0.5 / (1 - k_b)
            let scale_r:Double = 0.5 / (1 - k_r)

            let y:Double   = k_r * Double(r_diff) + k_g * Double(g_diff) + k_b * Double(b_diff) //[!], analog YCbCr!
            let c_b:Double = scale_b * (Double(b_diff) - y)
            let c_r:Double = scale_r * (Double(r_diff) - y)
            
            buffer[Int(i)] = Float(sqrt(pow(y, 2) + pow(c_b, 2) + pow(c_r, 2)))
        }
    }
    
    func distImpl(_ pix1: RawPixel, _ pix2: RawPixel) -> Double {
        //if (pix1 == pix2) -> 8% perf degradation!
        //    return 0;
        //if (pix1 > pix2)
        //	  std::swap(pix1, pix2); -> 30% perf degradation!!!
        
        let r_diff = Int(pix1.red) - Int(pix2.red)
        let g_diff = Int(pix1.green) - Int(pix2.green)
        let b_diff = Int(pix1.blue) - Int(pix2.blue)
        let buff_idx =
            (((r_diff + 255) / 2) << 16) | (((g_diff + 255) / 2) <<  8) | (( b_diff + 255) / 2)

        return Double(buffer[buff_idx])
    }
    static let inst = DistYCbCrBuffer()
    static func dist(_ pix1: RawPixel, _ pix2: RawPixel) -> Double {
        return inst.distImpl(pix1, pix2)
    }
}