//
//  Scaling.swift
//  sxBRZ
//
//  Created by Robert Armenski on 20.04.19.
//  Copyright © 2019 TitanTech. All rights reserved.
//

import Foundation

// swiftlint:disable identifier_name function_body_length function_parameter_count

func scaleImage(_ scaler: Scaler,
                _ colorDistance: ColorDistance,
                _ src: [RawPixel],
                _ trg: inout [RawPixel],
                _ srcWidth: Int, _ srcHeight: Int,
                _ cfg: ScalerConfiguration,
                _ yFirst: Int, _ yLast: Int) {
    let yFirst = max(yFirst, 0)
    let yLast = min(yLast, srcHeight)
    if yFirst >= yLast || srcWidth <= 0 {
        return
    }

    let trgWidth = srcWidth * scaler.scale
    //"use" space at the end of the image as temporary buffer
    //for "on the fly preprocessing": we even could use larger area of
    //"sizeof(uint32_t) * srcWidth * (yLast - yFirst)" bytes without risk
    //of accidental overwriting before accessing
    let bufferSize = srcWidth

    let trgPtr = UnsafeMutableRawPointer(&trg).assumingMemoryBound(to: RawPixelColor.self)
    let trgChar = trgPtr + yLast * scaler.scale * trgWidth
    let preProcBuffer = trgChar - bufferSize
    //var preProcBuffer = [RawPixelColor](repeating: 0, count: bufferSize)

    assert(BlendType.none.rawValue == 0, "Blend NONE is not 0")
    //initialize preprocessing buffer for first row of current stripe: detect upper left and right corner blending
    //this cannot be optimized for adjacent processing stripes; we must not allow for a memory race condition!
    if yFirst > 0 {
        let y: Int = yFirst - 1

        let s_m1 = srcWidth * max(y - 1, 0)
        let s_0  = srcWidth * y
        let s_p1 = srcWidth * min(y + 1, srcHeight - 1)
        let s_p2 = srcWidth * min(y + 2, srcHeight - 1)

        for x in 0..<srcWidth {
            let x_m1 = max(x - 1, 0)
            let x_p1 = min(x + 1, srcWidth - 1)
            let x_p2 = min(x + 2, srcWidth - 1)

            let ker = Kernel4x4(
                a: src[s_m1 + x_m1],
                b: src[s_m1 + x],
                c: src[s_m1 + x_p1],
                d: src[s_m1 + x_p2],
                e: src[s_0 + x_m1],
                f: src[s_0 + x],
                g: src[s_0 + x_p1],
                h: src[s_0 + x_p2],
                i: src[s_p1 + x_m1],
                j: src[s_p1 + x],
                k: src[s_p1 + x_p1],
                l: src[s_p1 + x_p2],
                m: src[s_p2 + x_m1],
                n: src[s_p2 + x],
                o: src[s_p2 + x_p1],
                p: src[s_p2 + x_p2]
            )

            let res = preProcessCorners(colorDistance, ker, cfg)
            /*
             preprocessing blend result:
             ---------
             | F | G |   //evalute corner between F, G, J, K
             ----|---|   //input pixel is at position F
             | J | K |
             ---------
             */
            preProcBuffer[x].setTopR(blend: res.blendJ)
            if x+1 < bufferSize {
                preProcBuffer[x+1].setTopL(blend: res.blendK)
            }
        }
    }
    //------------------------------------------------------------------------------------
    for y in yFirst..<yLast {
        var currOffset = scaler.scale * y * trgWidth

        let s_m1 = srcWidth * max(y - 1, 0)
        let s_0  = srcWidth * y
        let s_p1 = srcWidth * min(y + 1, srcHeight - 1)
        let s_p2 = srcWidth * min(y + 2, srcHeight - 1)

        var blend_xy1: RawPixelColor = 0
        for x in 0..<srcWidth {
            //all those bounds checks have only insignificant impact on performance!
            let x_m1 = max(x - 1, 0)
            let x_p1 = min(x + 1, srcWidth - 1)
            let x_p2 = min(x + 2, srcWidth - 1)

            let ker4 = Kernel4x4(
                a: src[s_m1 + x_m1],
                b: src[s_m1 + x],
                c: src[s_m1 + x_p1],
                d: src[s_m1 + x_p2],
                e: src[s_0 + x_m1],
                f: src[s_0 + x],
                g: src[s_0 + x_p1],
                h: src[s_0 + x_p2],
                i: src[s_p1 + x_m1],
                j: src[s_p1 + x],
                k: src[s_p1 + x_p1],
                l: src[s_p1 + x_p2],
                m: src[s_p2 + x_m1],
                n: src[s_p2 + x],
                o: src[s_p2 + x_p1],
                p: src[s_p2 + x_p2]
            )

            //for current (x, y) position
            //let blend_xyPtr = UnsafeMutablePointer<CUnsignedChar>([0])
            var blend_xy: RawPixelColor = 0

            let res = preProcessCorners(colorDistance, ker4, cfg) // res is identical
            /*
             preprocessing blend result:
             ---------
             | F | G |   //evalute corner between F, G, J, K
             ----|---|   //current input pixel is at position F
             | J | K |
             ---------
             */

            blend_xy = preProcBuffer[x]
            //all four corners of (x, y) have been determined at
            //this point due to processing sequence!
            blend_xy.setBottomR(blend: res.blendF)

            blend_xy1.setTopR(blend: res.blendJ) //set 2nd known corner for (x, y + 1)
            preProcBuffer[x] = blend_xy1 //store on current buffer position for use on next row

            blend_xy1 = 0
            //set 1st known corner for (x + 1, y + 1) and buffer for use on next column
            blend_xy1.setTopL(blend: res.blendK)

            if x + 1 < bufferSize {
                //set 3rd known corner for (x + 1, y)
                preProcBuffer[x + 1].setBottomL(blend: res.blendG)
            }

            // fill block of size scale * scale with the given color
            var tmpIt = currOffset
            for _ in 0..<scaler.scale {
                for x in 0..<scaler.scale {
                    trg[tmpIt + x] = ker4.f
                }
                tmpIt += trgWidth
            }

            //blend four corners of current pixel
            if blend_xy.blendingNeeded { //good 5% perf-improvement
                let ker3 = Kernel3x3(
                    a: ker4.a,
                    b: ker4.b,
                    c: ker4.c,
                    d: ker4.e,
                    e: ker4.f,
                    f: ker4.g,
                    g: ker4.i,
                    h: ker4.j,
                    i: ker4.k
                )
                //these are all equal in C++ code
                //print(NSString(format: "%d %d %d %d | %d %d %d %d", y, x, blend_xy, blend_xy1, res.blend_f.rawValue, res.blend_g.rawValue, res.blend_j.rawValue, res.blend_k.rawValue))
                //print("\(ker4)")
                //print("\(ker3)\n")

                blendPixel(
                    scaler, colorDistance, RotationDegree.zero, ker3, &trg, currOffset, trgWidth, blend_xy, cfg)
                blendPixel(
                    scaler, colorDistance, RotationDegree.rot90, ker3, &trg, currOffset, trgWidth, blend_xy, cfg)
                blendPixel(
                    scaler, colorDistance, RotationDegree.rot180, ker3, &trg, currOffset, trgWidth, blend_xy, cfg)
                blendPixel(
                    scaler, colorDistance, RotationDegree.rot270, ker3, &trg, currOffset, trgWidth, blend_xy, cfg)
            }
            currOffset += scaler.scale
        }
    }
}

private struct TupleKey: Hashable {
    let factor: UInt
    let format: ColorFormat
}

private let scalerInstance = cache { (key: TupleKey) -> Scaler in
    let gradient = key.format.gradient
    switch key.factor {
    case 2: return Scaler2x(gradient: gradient)
    case 3: return Scaler3x(gradient: gradient)
    case 4: return Scaler4x(gradient: gradient)
    case 5: return Scaler5x(gradient: gradient)
    case 6: return Scaler6x(gradient: gradient)
    default: fatalError("Unsupported scaling factor")
    }
}

public func scale(_ factor: UInt,
                  _ src: [UInt32],
                  _ trg: inout [UInt32],
                  _ srcWidth: Int,
                  _ srcHeight: Int,
                  _ colFmt: ColorFormat,
                  _ cfg: ScalerConfiguration,
                  _ yFirst: Int = 0,
                  _ yLast: Int = .max) {
    return scaleImage(scalerInstance(TupleKey(factor: factor, format: colFmt)),
                      colFmt.distance,
                      src, &trg,
                      srcWidth, srcHeight,
                      cfg, yFirst, yLast)
}
