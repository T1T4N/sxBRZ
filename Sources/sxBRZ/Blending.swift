//
// Created by T!T@N on 04.22.16.
// Copyright (c) 2016 TitanTech. All rights reserved.
//

import Foundation

// swiftlint:disable identifier_name function_parameter_count

func byteAdvance(_ ptr: UnsafeMutablePointer<RawPixel>, _ bytes: Int)
    -> UnsafeMutablePointer<RawPixel> {
        let tmpPtr = UnsafeMutableRawPointer(ptr)
            .assumingMemoryBound(to: RawPixelColor.self)
        return UnsafeMutableRawPointer(tmpPtr + bytes)
            .assumingMemoryBound(to: RawPixel.self)
}

// Fill block  with the given color
func fillBlock(_ target: UnsafeMutablePointer<RawPixel>,
               _ pitch: Int, _ col: RawPixel,
               _ blockWidth: Int, _ blockHeight: Int) {
    // Black on the diagonal if `target` used directly
    var targetPtr = UnsafeMutablePointer<UInt32>(target)
    for _ in 0..<blockHeight {
        for x in 0..<blockWidth {
            targetPtr[x] = col
        }
        // targetPtr += pitch
        targetPtr = byteAdvance(targetPtr, pitch)
    }
}

func fillBlock(_ trgPtr: UnsafeMutablePointer<RawPixel>,
               _ pitch: Int, _ col: RawPixel, _ n: Int) {
    fillBlock(trgPtr, pitch, col, n, n)
}

//func distRGB(_ pix1: UInt32, _ pix2: UInt32) -> Double {
//    let r_diff = Double(Int(pix1.red) - Int(pix2.red))
//    let g_diff = Double(Int(pix1.green) - Int(pix2.green))
//    let b_diff = Double(Int(pix1.blue) - Int(pix2.blue))
//
//    //euclidean RGB distance
//    return sqrt(pow(r_diff, 2) + pow(g_diff, 2) + pow(b_diff, 2))
//}

func preProcessCorners(_ colorDistance: ColorDistance,
                       _ ker: Kernel4x4,
                       _ cfg: ScalerConfiguration) -> BlendResult {
    //result: F, G, J, K corners of "GradientType"
    var result = BlendResult()

    if (ker.f == ker.g && ker.j == ker.k) ||
        (ker.f == ker.j && ker.g == ker.k) {
        return result
    }

    func dist(_ pix1: RawPixel, _ pix2: RawPixel) -> Double {
        return colorDistance.dist(pix1, pix2, cfg.luminanceWeight)
    }

    let weight = 4
    let jg =
        dist(ker.i, ker.f) +
            dist(ker.f, ker.c) +
            dist(ker.n, ker.k) +
            dist(ker.k, ker.h) +
            Double(weight) * dist(ker.j, ker.g)
    let fk =
        dist(ker.e, ker.j) +
            dist(ker.j, ker.o) +
            dist(ker.b, ker.g) +
            dist(ker.g, ker.l) +
            Double(weight) * dist(ker.f, ker.k)

    //test sample: 70% of values max(jg, fk) / min(jg, fk) are between 1.1 and 3.7 with median being 1.8
    if jg < fk {
        let dominantGradient: Bool = cfg.dominantDirectionThreshold * jg < fk
        if ker.f != ker.g && ker.f != ker.j {
            result.blendF = dominantGradient ? BlendType.dominant : BlendType.normal
        }
        if ker.k != ker.j && ker.k != ker.g {
            result.blendK = dominantGradient ? BlendType.dominant : BlendType.normal
        }
    } else if fk < jg {
        let dominantGradient: Bool = cfg.dominantDirectionThreshold * fk < jg
        if ker.j != ker.f && ker.j != ker.k {
            result.blendJ = dominantGradient ? BlendType.dominant : BlendType.normal
        }
        if ker.g != ker.f && ker.g != ker.k {
            result.blendG = dominantGradient ? BlendType.dominant : BlendType.normal
        }
    }
    return result
}

#if DEBUG
let breakIntoDebugger = false
#endif

func blendPixel(_ scaler: Scaler,
                _ colorDistance: ColorDistance,
                _ rotDeg: RotationDegree,
                _ ker: Kernel3x3,
                _ target: UnsafeMutablePointer<RawPixel>,
                _ trgWidth: Int,
                _ blendInfo: RawPixelColor,
                _ cfg: ScalerConfiguration) {
    let blend = blendInfo.rotateBlendInfo(rotDeg)
    if blend.bottomR.rawValue >= BlendType.normal.rawValue {

        func eq(_ pix1: RawPixel, _ pix2: RawPixel) -> Bool {
            return colorDistance.dist(pix1, pix2, cfg.luminanceWeight) < cfg.equalColorTolerance
        }

        func dist(_ pix1: RawPixel, _ pix2: RawPixel) -> Double {
            return colorDistance.dist(pix1, pix2, cfg.luminanceWeight)
        }

        let doLineBlend: Bool = {
            if blend.bottomR.rawValue >= BlendType.dominant.rawValue {
                return true
            }

            //make sure there is no second blending in an adjacent rotation
            //for this pixel: handles insular pixels, mario eyes
            if blend.topR != .none &&
                !eq(ker.getE(rotDeg),
                    ker.getG(rotDeg)) {
                return false
            }

            if blend.bottomL != .none &&
                !eq(ker.getE(rotDeg),
                    ker.getC(rotDeg)) {
                return false
            }

            //no full blending for L-shapes; blend corner only (handles "mario mushroom eyes")
            if !eq(ker.getE(rotDeg),
                   ker.getI(rotDeg)) &&
                eq(ker.getG(rotDeg),
                   ker.getH(rotDeg)) &&
                eq(ker.getH(rotDeg),
                   ker.getI(rotDeg)) &&
                eq(ker.getI(rotDeg),
                   ker.getF(rotDeg)) &&
                eq(ker.getF(rotDeg),
                   ker.getC(rotDeg)) {
                return false
            }
            return true
        }()

        //choose most similar color
        let px: RawPixel =
            dist(ker.getE(rotDeg), ker.getF(rotDeg)) <=
                dist(ker.getE(rotDeg), ker.getH(rotDeg)) ?
                    ker.getF(rotDeg) : ker.getH(rotDeg)

//        var out = OutputMatrix(UInt(scaler.scale), rotDeg, &target, trgWidth)
        if doLineBlend {
            let fg = dist(ker.getF(rotDeg), ker.getG(rotDeg))
            let hc = dist(ker.getH(rotDeg), ker.getC(rotDeg))
            let haveShallowLine: Bool = cfg.steepDirectionThreshold * fg <= hc &&
                ker.getE(rotDeg) != ker.getG(rotDeg) &&
                ker.getD(rotDeg) != ker.getG(rotDeg)
            let haveSteepLine: Bool   = cfg.steepDirectionThreshold * hc <= fg &&
                ker.getE(rotDeg) != ker.getC(rotDeg) &&
                ker.getB(rotDeg) != ker.getC(rotDeg)

            if haveShallowLine {
                if haveSteepLine {
                    scaler.blendLineSteepAndShallow(px, OutputMatrix.ref(UInt(scaler.scale),
                                                                         rotDeg, target, trgWidth))
                } else {
                    scaler.blendLineShallow(px, OutputMatrix.ref(UInt(scaler.scale),
                                                                 rotDeg, target, trgWidth))
                }
            } else {
                if haveSteepLine {
                    scaler.blendLineSteep(px, OutputMatrix.ref(UInt(scaler.scale),
                                                               rotDeg, target, trgWidth))
                } else {
                    scaler.blendLineDiagonal(px, OutputMatrix.ref(UInt(scaler.scale),
                                                                  rotDeg, target, trgWidth))
                }
            }
        } else {
            scaler.blendCorner(px, OutputMatrix.ref(UInt(scaler.scale),
                                                    rotDeg, target, trgWidth))
        }
    }
}

func blendPixel(_ scaler: Scaler,
                _ colorDistance: ColorDistance,
                _ rotDeg: RotationDegree,
                _ ker: Kernel3x3,
                _ target: inout [RawPixel],
                _ currentOffset: Int,
                _ trgWidth: Int,
                _ blendInfo: CUnsignedChar,
                _ cfg: ScalerConfiguration) {
    let blend = blendInfo.rotateBlendInfo(rotDeg)
    if blend.bottomR.rawValue >= BlendType.normal.rawValue {

        func eq(_ pix1: RawPixel, _ pix2: RawPixel) -> Bool {
            return colorDistance.dist(pix1, pix2, cfg.luminanceWeight) < cfg.equalColorTolerance
        }

        func dist(_ pix1: RawPixel, _ pix2: RawPixel) -> Double {
            return colorDistance.dist(pix1, pix2, cfg.luminanceWeight)
        }

        let doLineBlend: Bool = {
            if blend.bottomR.rawValue >= BlendType.dominant.rawValue {
                return true
            }
            //make sure there is no second blending in an adjacent rotation
            //for this pixel: handles insular pixels, mario eyes
            if blend.topR != .none &&
                !eq(ker.getE(rotDeg),
                    ker.getG(rotDeg)) {
                return false
            }
            if blend.bottomL != .none &&
                !eq(ker.getE(rotDeg),
                    ker.getC(rotDeg)) {
                return false
            }

            //no full blending for L-shapes; blend corner only (handles "mario mushroom eyes")
            if !eq(ker.getE(rotDeg),
                   ker.getI(rotDeg)) &&
                eq(ker.getG(rotDeg),
                   ker.getH(rotDeg)) &&
                eq(ker.getH(rotDeg),
                   ker.getI(rotDeg)) &&
                eq(ker.getI(rotDeg),
                   ker.getF(rotDeg)) &&
                eq(ker.getF(rotDeg),
                   ker.getC(rotDeg)) {
                return false
            }
            return true
        }()

        //choose most similar color
        let px: RawPixel =
            dist(ker.getE(rotDeg), ker.getF(rotDeg)) <=
                dist(ker.getE(rotDeg), ker.getH(rotDeg)) ?
                    ker.getF(rotDeg) : ker.getH(rotDeg)

        //        var out = OutputMatrix(UInt(scaler.scale), rotDeg, out: &target, currentOffset, trgWidth)
        if doLineBlend {
            let fg = dist(ker.getF(rotDeg), ker.getG(rotDeg))
            let hc = dist(ker.getH(rotDeg), ker.getC(rotDeg))
            let haveShallowLine = cfg.steepDirectionThreshold * fg <= hc &&
                ker.getE(rotDeg) != ker.getG(rotDeg) &&
                ker.getD(rotDeg) != ker.getG(rotDeg)
            let haveSteepLine   = cfg.steepDirectionThreshold * hc <= fg &&
                ker.getE(rotDeg) != ker.getC(rotDeg) &&
                ker.getB(rotDeg) != ker.getC(rotDeg)

            if haveShallowLine {
                if haveSteepLine {
                    scaler.blendLineSteepAndShallow(px, OutputMatrix.ref(
                        UInt(scaler.scale), rotDeg, &target, currentOffset, trgWidth))
                } else {
                    scaler.blendLineShallow(px, OutputMatrix.ref(
                        UInt(scaler.scale), rotDeg, &target, currentOffset, trgWidth))
                }
            } else {
                if haveSteepLine {
                    scaler.blendLineSteep(px, OutputMatrix.ref(
                        UInt(scaler.scale), rotDeg, &target, currentOffset, trgWidth))
                } else {
                    scaler.blendLineDiagonal(px, OutputMatrix.ref(
                        UInt(scaler.scale), rotDeg, &target, currentOffset, trgWidth))
                }
            }
        } else {
            scaler.blendCorner(px, OutputMatrix.ref(
                UInt(scaler.scale), rotDeg, &target, currentOffset, trgWidth))
        }
    }
}
