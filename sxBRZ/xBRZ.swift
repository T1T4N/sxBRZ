//
// Created by T!T@N on 04.22.16.
// Copyright (c) 2016 TitanTech. All rights reserved.
//

import Foundation

func getByte(_ N: UInt32, val: UInt32) -> CUnsignedChar {
    return CUnsignedChar((val >> (8 * N)) & 0xff)
}
func getAlpha(_ pix: UInt32) -> CUnsignedChar {
    return getByte(3, val: pix)
}
func getRed(_ pix: UInt32) -> CUnsignedChar {
    return getByte(2, val: pix)
}
func getGreen(_ pix: UInt32) -> CUnsignedChar {
    return getByte(1, val: pix)
}
func getBlue(_ pix: UInt32) -> CUnsignedChar {
    return getByte(0, val: pix)
}

func makePixel(_ r: CUnsignedChar, _ g: CUnsignedChar, _ b: CUnsignedChar) -> UInt32 {
    return (UInt32(r) << 16) | (UInt32(g) << 8) | UInt32(b)
}

func makePixel(_ a: CUnsignedChar, _ r: CUnsignedChar, _ g: CUnsignedChar, _ b: CUnsignedChar) -> UInt32 {
    return (UInt32(a) << 24) | (UInt32(r) << 16) | (UInt32(g) << 8) | UInt32(b)
}

func byteAdvance(_ ptr: UnsafeMutablePointer<UInt32>, _ bytes:Int) -> UnsafeMutablePointer<UInt32> {
    let tmpPtr = UnsafeMutableRawPointer(ptr).assumingMemoryBound(to: CUnsignedChar.self)
    //let tmpPtr = UnsafeMutablePointer<CUnsignedChar>(ptr)
    //return UnsafeMutablePointer<UInt32>(tmpPtr + bytes)
    let ret = tmpPtr + bytes
    return UnsafeMutableRawPointer(ret).assumingMemoryBound(to: UInt32.self)
}

// Fill block  with the given color
func fillBlock(_ trg: inout UnsafeMutablePointer<UInt32>, _ pitch:Int, _ col: UInt32, _ blockWidth:Int, _ blockHeight: Int) {
    var trgPt = UnsafeMutablePointer<UInt32>(trg)
    for _ in 0..<blockHeight {
        for x in 0..<blockWidth {
            trgPt[x] = col
        }
        // trgPt += pitch
        trgPt = byteAdvance(trgPt, pitch)
    }
}
func fillBlock(_ trg: inout UnsafeMutablePointer<UInt32>, _ pitch:Int, _ col: UInt32, _ n:Int) {
    fillBlock(&trg, pitch, col, n, n)
}

func distRGB(_ pix1: UInt32, _ pix2: UInt32) -> Double
{
    let r_diff = Double(Int(getRed  (pix1)) - Int(getRed  (pix2)))
    let g_diff = Double(Int(getGreen(pix1)) - Int(getGreen(pix2)))
    let b_diff = Double(Int(getBlue (pix1)) - Int(getBlue (pix2)))

    //euclidean RGB distance
    return sqrt(pow(r_diff, 2) + pow(g_diff, 2) + pow(b_diff, 2))
}

func preProcessCorners(_ colorDistance:ColorDistance.Type, _ ker:Kernel_4x4, _ cfg:ScalerCfg) -> BlendResult
{
    //result: F, G, J, K corners of "GradientType"
    var result = BlendResult()

    if ((ker.f == ker.g &&
         ker.j == ker.k) ||
        (ker.f == ker.j &&
         ker.g == ker.k)) {
        return result
    }

    func dist(_ pix1:UInt32, _ pix2: UInt32) -> Double {
        return colorDistance.dist(pix1, pix2, cfg.luminanceWeight)
    }

    let weight:Int = 4
    let jg:Double = dist(ker.i, ker.f) + dist(ker.f, ker.c) + dist(ker.n, ker.k) + dist(ker.k, ker.h) + Double(weight) * dist(ker.j, ker.g)
    let fk:Double = dist(ker.e, ker.j) + dist(ker.j, ker.o) + dist(ker.b, ker.g) + dist(ker.g, ker.l) + Double(weight) * dist(ker.f, ker.k)

    //test sample: 70% of values max(jg, fk) / min(jg, fk) are between 1.1 and 3.7 with median being 1.8
    if jg < fk
    {
        let dominantGradient:Bool = cfg.dominantDirectionThreshold * jg < fk
        if ker.f != ker.g && ker.f != ker.j {
            result.blend_f = dominantGradient ? BlendType.dominant : BlendType.normal
        }
        if ker.k != ker.j && ker.k != ker.g {
            result.blend_k = dominantGradient ? BlendType.dominant : BlendType.normal
        }
    }
    else if fk < jg
    {
        let dominantGradient:Bool = cfg.dominantDirectionThreshold * fk < jg
        if ker.j != ker.f && ker.j != ker.k {
            result.blend_j = dominantGradient ? BlendType.dominant : BlendType.normal
        }
        if ker.g != ker.f && ker.g != ker.k {
            result.blend_g = dominantGradient ? BlendType.dominant : BlendType.normal
        }
    }
    return result
}

//template <RotationDegree rotDeg> uint32_t inline get_##x(const Kernel_3x3& ker) { return ker.x; }
func get_a(_ rotDeg: RotationDegree, _ ker:Kernel_3x3) -> UInt32 {
    switch rotDeg {
    case .rot_0:
        return ker.a
    case .rot_90:
        return ker.g
    case .rot_180:
        return ker.i
    case .rot_270:
        return ker.c
    }
}
func get_b(_ rotDeg: RotationDegree, _ ker:Kernel_3x3) -> UInt32 {
    switch rotDeg {
    case .rot_0:
        return ker.b
    case .rot_90:
        return ker.d
    case .rot_180:
        return ker.h
    case .rot_270:
        return ker.f
    }
}
func get_c(_ rotDeg: RotationDegree, _ ker:Kernel_3x3) -> UInt32 {
    switch rotDeg {
    case .rot_0:
        return ker.c
    case .rot_90:
        return ker.a
    case .rot_180:
        return ker.g
    case .rot_270:
        return ker.i
    }
}
func get_d(_ rotDeg: RotationDegree, _ ker:Kernel_3x3) -> UInt32 {
    switch rotDeg {
    case .rot_0:
        return ker.d
    case .rot_90:
        return ker.h
    case .rot_180:
        return ker.f
    case .rot_270:
        return ker.b
    }
}

func get_e(_ rotDeg: RotationDegree, _ ker:Kernel_3x3) -> UInt32 { return ker.e }

func get_f(_ rotDeg: RotationDegree, _ ker:Kernel_3x3) -> UInt32 {
    switch rotDeg {
    case .rot_0:
        return ker.f
    case .rot_90:
        return ker.b
    case .rot_180:
        return ker.d
    case .rot_270:
        return ker.h
    }
}
func get_g(_ rotDeg: RotationDegree, _ ker:Kernel_3x3) -> UInt32 {
    switch rotDeg {
    case .rot_0:
        return ker.g
    case .rot_90:
        return ker.i
    case .rot_180:
        return ker.c
    case .rot_270:
        return ker.a
    }
}
func get_h(_ rotDeg: RotationDegree, _ ker:Kernel_3x3) -> UInt32 {
    switch rotDeg {
    case .rot_0:
        return ker.h
    case .rot_90:
        return ker.f
    case .rot_180:
        return ker.b
    case .rot_270:
        return ker.d
    }
}
func get_i(_ rotDeg: RotationDegree, _ ker:Kernel_3x3) -> UInt32 {
    switch rotDeg {
    case .rot_0:
        return ker.i
    case .rot_90:
        return ker.c
    case .rot_180:
        return ker.a
    case .rot_270:
        return ker.g
    }
}

func getTopL   (_ b:CUnsignedChar) -> BlendType { return BlendType(rawValue: ((0x3 & b)%3))! }
func getTopR   (_ b:CUnsignedChar) -> BlendType { return BlendType(rawValue: ((0x3 & (b >> 2))%3))! }
func getBottomR   (_ b:CUnsignedChar) -> BlendType { return BlendType(rawValue: ((0x3 & (b >> 4))%3))! }
func getBottomL   (_ b:CUnsignedChar) -> BlendType { return BlendType(rawValue: ((0x3 & (b >> 6))%3))! }

//buffer is assumed to be initialized before preprocessing!
func setTopL (_ b:inout CUnsignedChar, _ bt:BlendType) { b |= bt.rawValue }
//func setTopL (b:UnsafeMutablePointer<CUnsignedChar>, _ idx:Int, _ bt:BlendType) {
//    let bPt = UnsafeMutablePointer<CUnsignedChar>(b)
//    bPt[idx] |= bt.rawValue
//}
func setTopL (_ b:inout [CUnsignedChar], _ idx:Int, _ bt:BlendType) {
    b[idx] |= bt.rawValue
}

func setTopR (_ b:inout CUnsignedChar, _ bt:BlendType) { b |= (bt.rawValue << 2) }
//func setTopR (b:UnsafeMutablePointer<CUnsignedChar>, _ idx:Int, _ bt:BlendType) {
//    let bPt = UnsafeMutablePointer<CUnsignedChar>(b)
//    bPt[idx] |= (bt.rawValue << 2)
//}
func setTopR (_ b:inout [CUnsignedChar], _ idx:Int, _ bt:BlendType) {
    b[idx] |= (bt.rawValue << 2)
}


func setBottomR (_ b:inout CUnsignedChar, _ bt:BlendType) { b |= (bt.rawValue << 4) }
//func setBottomR (b:UnsafeMutablePointer<CUnsignedChar>, _ idx:Int, _ bt:BlendType) {
//    let bPt = UnsafeMutablePointer<CUnsignedChar>(b)
//    bPt[idx] |= (bt.rawValue << 4)
//}
func setBottomR (_ b:inout [CUnsignedChar], _ idx:Int, _ bt:BlendType) {
    b[idx] |= (bt.rawValue << 4)
}

func setBottomL (_ b:inout CUnsignedChar, _ bt:BlendType) { b |= (bt.rawValue << 6) }
//func setBottomL (b:UnsafeMutablePointer<CUnsignedChar>, _ idx:Int, _ bt:BlendType) {
//    let bPt = UnsafeMutablePointer<CUnsignedChar>(b)
//    bPt[idx] |= (bt.rawValue << 6)
//}
func setBottomL (_ b:inout [CUnsignedChar], _ idx:Int, _ bt:BlendType) {
    b[idx] |= (bt.rawValue << 6)
}

func blendingNeeded(_ b:CUnsignedChar) -> Bool { return b != 0 }

func rotateBlendInfo(_ rotDeg:RotationDegree, _ b:CUnsignedChar) -> CUnsignedChar {
    switch rotDeg {
    case .rot_0:
        return b
    case .rot_90:
        return ((b << 2) | (b >> 6)) & 0xff
    case .rot_180:
        return ((b << 4) | (b >> 4)) & 0xff
    case .rot_270:
        return ((b << 6) | (b >> 2)) & 0xff
    }
}

#if DEBUG
    let breakIntoDebugger = false
#endif

func blendPixel(_ scaler:Scaler.Type, _ colorDistance:ColorDistance.Type, _ rotDeg:RotationDegree, _ ker:Kernel_3x3, _ targetPt: inout UnsafeMutablePointer<UInt32>, _ trgWidth: Int, _ blendInfo:CUnsignedChar, _ cfg:ScalerCfg) {
//    var a = get_a(rotDeg, &ker)
//    var b = get_b(rotDeg, &ker)
//    var c = get_c(rotDeg, &ker)
//    var d = get_d(rotDeg, &ker)
//    var e = get_e(rotDeg, &ker)
//    var f = get_f(rotDeg, &ker)
//    var g = get_g(rotDeg, &ker)
//    var h = get_h(rotDeg, &ker)
//    var i = get_i(rotDeg, &ker)
    var target = UnsafeMutablePointer<UInt32>(targetPt)
    
    var blend = rotateBlendInfo(rotDeg, blendInfo)
    if getBottomR(blend).rawValue >= BlendType.normal.rawValue {
        func eq(_ pix1:UInt32, _ pix2:UInt32) -> Bool {
            return colorDistance.dist(pix1, pix2, cfg.luminanceWeight) < cfg.equalColorTolerance
        }
        func dist(_ pix1:UInt32, _ pix2:UInt32) -> Double {
            return colorDistance.dist(pix1, pix2, cfg.luminanceWeight)
        }

        let doLineBlend:Bool =  {
            if getBottomR(blend).rawValue >= BlendType.dominant.rawValue {
                return true
            }
            //make sure there is no second blending in an adjacent rotation for this pixel: handles insular pixels, mario eyes
            if getTopR(blend) != BlendType.none &&
                !eq(get_e(rotDeg, ker),
                    get_g(rotDeg, ker)) {
                return false
            }
            if getBottomL(blend) != BlendType.none &&
                !eq(get_e(rotDeg, ker),
                    get_c(rotDeg, ker)) {
                return false
            }

            //no full blending for L-shapes; blend corner only (handles "mario mushroom eyes")
            if !eq(get_e(rotDeg, ker),
                   get_i(rotDeg, ker)) &&
                eq(get_g(rotDeg, ker),
                   get_h(rotDeg, ker)) &&
                eq(get_h(rotDeg, ker),
                   get_i(rotDeg, ker)) &&
                eq(get_i(rotDeg, ker),
                   get_f(rotDeg, ker)) &&
                eq(get_f(rotDeg, ker),
                   get_c(rotDeg, ker)) {
                return false
            }
            return true
        }()

        //choose most similar color
        let px:UInt32 = dist(get_e(rotDeg, ker), get_f(rotDeg, ker)) <= dist(get_e(rotDeg, ker), get_h(rotDeg, ker)) ? get_f(rotDeg, ker) : get_h(rotDeg, ker)
        
//        var out = OutputMatrix(UInt(scaler.scale), rotDeg, &target, trgWidth)
        if doLineBlend {
            let fg = dist(get_f(rotDeg, ker), get_g(rotDeg, ker))
            let hc = dist(get_h(rotDeg, ker), get_c(rotDeg, ker))
            let haveShallowLine:Bool = cfg.steepDirectionThreshold * fg <= hc && get_e(rotDeg, ker) != get_g(rotDeg, ker) && get_d(rotDeg, ker) != get_g(rotDeg, ker)
            let haveSteepLine:Bool   = cfg.steepDirectionThreshold * hc <= fg && get_e(rotDeg, ker) != get_c(rotDeg, ker) && get_b(rotDeg, ker) != get_c(rotDeg, ker)

            if haveShallowLine {
                if haveSteepLine {
                    scaler.blendLineSteepAndShallow(px, OutputMatrix.ref(UInt(scaler.scale), rotDeg, target, trgWidth))
                }
                else {
                    scaler.blendLineShallow(px, OutputMatrix.ref(UInt(scaler.scale), rotDeg, target, trgWidth))
                }
            }
            else {
                if haveSteepLine {
                    scaler.blendLineSteep(px, OutputMatrix.ref(UInt(scaler.scale), rotDeg, target, trgWidth))
                }
                else {
                    scaler.blendLineDiagonal(px, OutputMatrix.ref(UInt(scaler.scale), rotDeg, target, trgWidth))
                }
            }
        }
        else {
            scaler.blendCorner(px, OutputMatrix.ref(UInt(scaler.scale), rotDeg, target, trgWidth))
        }
    }
}

func blendPixel(_ scaler:Scaler.Type, _ colorDistance:ColorDistance.Type, _ rotDeg:RotationDegree, _ ker:Kernel_3x3, _ target: inout [UInt32], _ currentOffset: Int, _ trgWidth: Int, _ blendInfo:CUnsignedChar, _ cfg:ScalerCfg) {
    //    var a = get_a(rotDeg, &ker)
    //    var b = get_b(rotDeg, &ker)
    //    var c = get_c(rotDeg, &ker)
    //    var d = get_d(rotDeg, &ker)
    //    var e = get_e(rotDeg, &ker)
    //    var f = get_f(rotDeg, &ker)
    //    var g = get_g(rotDeg, &ker)
    //    var h = get_h(rotDeg, &ker)
    //    var i = get_i(rotDeg, &ker)
    
    var blend = rotateBlendInfo(rotDeg, blendInfo)
    if getBottomR(blend).rawValue >= BlendType.normal.rawValue {
        func eq(_ pix1:UInt32, _ pix2:UInt32) -> Bool {
            return colorDistance.dist(pix1, pix2, cfg.luminanceWeight) < cfg.equalColorTolerance
        }
        func dist(_ pix1:UInt32, _ pix2:UInt32) -> Double {
            return colorDistance.dist(pix1, pix2, cfg.luminanceWeight)
        }
        
        let doLineBlend:Bool =  {
            if getBottomR(blend).rawValue >= BlendType.dominant.rawValue {
                return true
            }
            //make sure there is no second blending in an adjacent rotation for this pixel: handles insular pixels, mario eyes
            if getTopR(blend) != BlendType.none &&
                !eq(get_e(rotDeg, ker),
                    get_g(rotDeg, ker)) {
                return false
            }
            if getBottomL(blend) != BlendType.none &&
                !eq(get_e(rotDeg, ker),
                    get_c(rotDeg, ker)) {
                return false
            }
            
            //no full blending for L-shapes; blend corner only (handles "mario mushroom eyes")
            if !eq(get_e(rotDeg, ker),
                   get_i(rotDeg, ker)) &&
                eq(get_g(rotDeg, ker),
                   get_h(rotDeg, ker)) &&
                eq(get_h(rotDeg, ker),
                   get_i(rotDeg, ker)) &&
                eq(get_i(rotDeg, ker),
                   get_f(rotDeg, ker)) &&
                eq(get_f(rotDeg, ker),
                   get_c(rotDeg, ker)) {
                return false
            }
            return true
        }()
        
        //choose most similar color
        let px:UInt32 = dist(get_e(rotDeg, ker), get_f(rotDeg, ker)) <= dist(get_e(rotDeg, ker), get_h(rotDeg, ker)) ? get_f(rotDeg, ker) : get_h(rotDeg, ker)
        
//        var out = OutputMatrix(UInt(scaler.scale), rotDeg, out: &target, currentOffset, trgWidth)
        if doLineBlend {
            let fg:Double = dist(get_f(rotDeg, ker), get_g(rotDeg, ker))
            let hc:Double = dist(get_h(rotDeg, ker), get_c(rotDeg, ker))
            let haveShallowLine:Bool = cfg.steepDirectionThreshold * fg <= hc && get_e(rotDeg, ker) != get_g(rotDeg, ker) && get_d(rotDeg, ker) != get_g(rotDeg, ker)
            let haveSteepLine:Bool   = cfg.steepDirectionThreshold * hc <= fg && get_e(rotDeg, ker) != get_c(rotDeg, ker) && get_b(rotDeg, ker) != get_c(rotDeg, ker)
            
            if haveShallowLine {
                if haveSteepLine {
                    scaler.blendLineSteepAndShallow(px, OutputMatrix.ref(UInt(scaler.scale), rotDeg, target, currentOffset, trgWidth))
                }
                else {
                    scaler.blendLineShallow(px, OutputMatrix.ref(UInt(scaler.scale), rotDeg, target,currentOffset,  trgWidth))
                }
            }
            else {
                if haveSteepLine {
                    scaler.blendLineSteep(px, OutputMatrix.ref(UInt(scaler.scale), rotDeg, target,currentOffset,  trgWidth))
                }
                else {
                    scaler.blendLineDiagonal(px, OutputMatrix.ref(UInt(scaler.scale), rotDeg, target,currentOffset,  trgWidth))
                }
            }
        }
        else {
            scaler.blendCorner(px, OutputMatrix.ref(UInt(scaler.scale), rotDeg, target,currentOffset,  trgWidth))
        }
    }
}

func scaleImage(_ scaler:Scaler.Type, _ colorDistance:ColorDistance.Type, _ srcPt: UnsafeMutablePointer<UInt32>, _ trgPt: inout UnsafeMutablePointer<UInt32>, _ srcWidth:Int, _ srcHeight:Int, _ cfg:ScalerCfg, _ yFirst:Int, _ yLast:Int) {
    let yFirst = max(yFirst, 0)
    let yLast = min(yLast, srcHeight)
    if yFirst >= yLast || srcWidth <= 0 {
        return
    }
    let src = UnsafeMutablePointer<UInt32>(srcPt)
    let trg = UnsafeMutablePointer<UInt32>(trgPt)
    
    let trgWidth = srcWidth * scaler.scale
    //"use" space at the end of the image as temporary buffer for "on the fly preprocessing": we even could use larger area of
    //"sizeof(uint32_t) * srcWidth * (yLast - yFirst)" bytes without risk of accidental overwriting before accessing
    let bufferSize = srcWidth

//    let trgChar = UnsafeMutablePointer<CUnsignedChar>(trg + yLast * scaler.scale * trgWidth)
//    let preProcBuffer:UnsafeMutablePointer<CUnsignedChar> = trgChar - bufferSize
    var preProcBuffer = [CUnsignedChar](repeating: 0, count: bufferSize)
    
    assert(BlendType.none.rawValue == 0, "Blend NONE is not 0")
    //initialize preprocessing buffer for first row of current stripe: detect upper left and right corner blending
    //this cannot be optimized for adjacent processing stripes; we must not allow for a memory race condition!
    if yFirst > 0
    {
        let y:Int = yFirst - 1

        let s_m1:UnsafeMutablePointer<UInt32> = src + srcWidth * max(y - 1, 0)
        let s_0:UnsafeMutablePointer<UInt32>  = src + srcWidth * y
        let s_p1:UnsafeMutablePointer<UInt32> = src + srcWidth * min(y + 1, srcHeight - 1)
        let s_p2:UnsafeMutablePointer<UInt32> = src + srcWidth * min(y + 2, srcHeight - 1)

        for x in 0..<srcWidth {
            let x_m1 = max(x - 1, 0)
            let x_p1 = min(x + 1, srcWidth - 1)
            let x_p2 = min(x + 2, srcWidth - 1)

            let ker = Kernel_4x4(
                a: s_m1[x_m1],
                b: s_m1[x],
                c: s_m1[x_p1],
                d: s_m1[x_p2],
                e: s_0[x_m1],
                f: s_0[x],
                g: s_0[x_p1],
                h: s_0[x_p2],
                i: s_p1[x_m1],
                j: s_p1[x],
                k: s_p1[x_p1],
                l: s_p1[x_p2],
                m: s_p2[x_m1],
                n: s_p2[x],
                o: s_p2[x_p1],
                p: s_p2[x_p2]
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
            setTopR(&preProcBuffer, x, res.blend_j)
            if x+1 < bufferSize {
                setTopL(&preProcBuffer, x+1, res.blend_k)
            }
        }
    }
    //------------------------------------------------------------------------------------
    for y in yFirst..<yLast {
        var out:UnsafeMutablePointer<UInt32> = trg + scaler.scale * y * trgWidth

        let s_m1:UnsafeMutablePointer<UInt32> = src + srcWidth * max(y - 1, 0)
        let s_0:UnsafeMutablePointer<UInt32>  = src + srcWidth * y
        let s_p1:UnsafeMutablePointer<UInt32> = src + srcWidth * min(y + 1, srcHeight - 1)
        let s_p2:UnsafeMutablePointer<UInt32> = src + srcWidth * min(y + 2, srcHeight - 1)

        var blend_xy1 = [CUnsignedChar](repeating: 0, count: 1)
        for x in 0..<srcWidth {
            //all those bounds checks have only insignificant impact on performance!
            let x_m1 = max(x - 1, 0)
            let x_p1 = min(x + 1, srcWidth - 1)
            let x_p2 = min(x + 2, srcWidth - 1)

            let ker4 = Kernel_4x4(
                a: s_m1[x_m1],
                b: s_m1[x],
                c: s_m1[x_p1],
                d: s_m1[x_p2],
                e: s_0[x_m1],
                f: s_0[x],
                g: s_0[x_p1],
                h: s_0[x_p2],
                i: s_p1[x_m1],
                j: s_p1[x],
                k: s_p1[x_p1],
                l: s_p1[x_p2],
                m: s_p2[x_m1],
                n: s_p2[x],
                o: s_p2[x_p1],
                p: s_p2[x_p2]
            )
//            let blend_xyPtr = UnsafeMutablePointer<CUnsignedChar>([0]) //for current (x, y) position
            var blend_xy = [CUnsignedChar](repeating: 0, count: 1)
            let res = preProcessCorners(colorDistance, ker4, cfg) // res is identical
            /*
             preprocessing blend result:
             ---------
             | F | G |   //evalute corner between F, G, J, K
             ----|---|   //current input pixel is at position F
             | J | K |
             ---------
             */

            blend_xy[0] = preProcBuffer[x]
            setBottomR(&blend_xy, 0, res.blend_f) //all four corners of (x, y) have been determined at this point due to processing sequence!

            setTopR(&blend_xy1, 0, res.blend_j) //set 2nd known corner for (x, y + 1)
            preProcBuffer[x] = blend_xy1[0] //store on current buffer position for use on next row
            
            blend_xy1[0] = 0
            setTopL(&blend_xy1, 0, res.blend_k) //set 1st known corner for (x + 1, y + 1) and buffer for use on next column

            if (x + 1 < bufferSize) {
                //set 3rd known corner for (x + 1, y)
                setBottomL(&preProcBuffer, x + 1, res.blend_g)
            }
            
            // fill block of size scale * scale with the given color
            fillBlock(&out, trgWidth * MemoryLayout<UInt32>.size, ker4.f, scaler.scale) //place *after* preprocessing step, to not overwrite the results while processing the the last pixel!
            // fillBlock(out, trgWidth, ker4.f, scaler.scale)

            //blend four corners of current pixel
            if blendingNeeded(blend_xy[0]) { //good 5% perf-improvement
                let ker3 = Kernel_3x3(
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
                blendPixel(
                    scaler, colorDistance, RotationDegree.rot_0, ker3, &out, trgWidth, blend_xy[0], cfg)
                blendPixel(
                    scaler, colorDistance, RotationDegree.rot_90, ker3, &out, trgWidth, blend_xy[0], cfg)
                blendPixel(
                    scaler, colorDistance, RotationDegree.rot_180, ker3, &out, trgWidth, blend_xy[0], cfg)
                blendPixel(
                    scaler, colorDistance, RotationDegree.rot_270, ker3, &out, trgWidth, blend_xy[0], cfg)
            }
            out += scaler.scale
        }
    }
}


func scaleImage(_ scaler:Scaler.Type, _ colorDistance:ColorDistance.Type, _ src: [UInt32], _ trg: inout [UInt32], _ srcWidth:Int, _ srcHeight:Int, _ cfg:ScalerCfg, _ yFirst:Int, _ yLast:Int) {
    let yFirst = max(yFirst, 0)
    let yLast = min(yLast, srcHeight)
    if yFirst >= yLast || srcWidth <= 0 {
        return
    }
    
    let trgWidth = srcWidth * scaler.scale
    //"use" space at the end of the image as temporary buffer for "on the fly preprocessing": we even could use larger area of
    //"sizeof(uint32_t) * srcWidth * (yLast - yFirst)" bytes without risk of accidental overwriting before accessing
    let bufferSize = srcWidth
    
    //    let trgChar = UnsafeMutablePointer<CUnsignedChar>(trg + yLast * scaler.scale * trgWidth)
    //    let preProcBuffer:UnsafeMutablePointer<CUnsignedChar> = trgChar - bufferSize
    var preProcBuffer = [CUnsignedChar](repeating: 0, count: bufferSize)
    
    assert(BlendType.none.rawValue == 0, "Blend NONE is not 0")
    //initialize preprocessing buffer for first row of current stripe: detect upper left and right corner blending
    //this cannot be optimized for adjacent processing stripes; we must not allow for a memory race condition!
    if yFirst > 0
    {
        let y:Int = yFirst - 1
        
        let s_m1 = srcWidth * max(y - 1, 0)
        let s_0  = srcWidth * y
        let s_p1 = srcWidth * min(y + 1, srcHeight - 1)
        let s_p2 = srcWidth * min(y + 2, srcHeight - 1)
        
        for x in 0..<srcWidth {
            let x_m1 = max(x - 1, 0)
            let x_p1 = min(x + 1, srcWidth - 1)
            let x_p2 = min(x + 2, srcWidth - 1)
            
            let ker = Kernel_4x4(
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
            setTopR(&preProcBuffer[x], res.blend_j)
            if x+1 < bufferSize {
                setTopL(&preProcBuffer[x+1], res.blend_k)
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
        
        var blend_xy1:CUnsignedChar = 0
        for x in 0..<srcWidth {
            //all those bounds checks have only insignificant impact on performance!
            let x_m1 = max(x - 1, 0)
            let x_p1 = min(x + 1, srcWidth - 1)
            let x_p2 = min(x + 2, srcWidth - 1)
            
            let ker4 = Kernel_4x4(
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
            //            let blend_xyPtr = UnsafeMutablePointer<CUnsignedChar>([0]) //for current (x, y) position
            var blend_xy:CUnsignedChar = 0
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
            setBottomR(&blend_xy, res.blend_f) //all four corners of (x, y) have been determined at this point due to processing sequence!
            
            setTopR(&blend_xy1, res.blend_j) //set 2nd known corner for (x, y + 1)
            preProcBuffer[x] = blend_xy1 //store on current buffer position for use on next row
            
            blend_xy1 = 0
            setTopL(&blend_xy1, res.blend_k) //set 1st known corner for (x + 1, y + 1) and buffer for use on next column
            
            if (x + 1 < bufferSize) {
                //set 3rd known corner for (x + 1, y)
                setBottomL(&preProcBuffer[x + 1], res.blend_g)
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
            if blendingNeeded(blend_xy) { //good 5% perf-improvement
                let ker3 = Kernel_3x3(
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
//                these are all equal in C++ code
//                print(NSString(format: "%d %d %d %d | %d %d %d %d", y, x, blend_xy, blend_xy1, res.blend_f.rawValue, res.blend_g.rawValue, res.blend_j.rawValue, res.blend_k.rawValue))
//                print("\(ker4)")
//                print("\(ker3)\n")
                
                blendPixel(
                    scaler, colorDistance, RotationDegree.rot_0, ker3, &trg, currOffset, trgWidth, blend_xy, cfg)
                blendPixel(
                    scaler, colorDistance, RotationDegree.rot_90, ker3, &trg, currOffset, trgWidth, blend_xy, cfg)
                blendPixel(
                    scaler, colorDistance, RotationDegree.rot_180, ker3, &trg, currOffset, trgWidth, blend_xy, cfg)
                blendPixel(
                    scaler, colorDistance, RotationDegree.rot_270, ker3, &trg, currOffset, trgWidth, blend_xy, cfg)
            }
            currOffset += scaler.scale
        }
//        print("\(y)")
//        for z in 0..<bufferSize {
//            print(preProcBuffer[z], separator: " ", terminator: " ")
//        }
//        print("\n")
    }
}

func scale(_ factor: UInt, _ src: UnsafeMutablePointer<UInt32>, _ trg: inout UnsafeMutablePointer<UInt32>, _ srcWidth:Int, _ srcHeight:Int, _ colFmt:ColorFormat, _ cfg:ScalerCfg, _ yFirst:Int = 0, _ yLast:Int = Int.max) {
    switch colFmt {
    case .argb:
        switch factor {
        case 2:
            return scaleImage(Scaler2x<ColorGradientARGB>.self, ColorDistanceARGB.self, src, &trg, srcWidth, srcHeight, cfg, yFirst, yLast)
        case 3:
            return scaleImage(Scaler3x<ColorGradientARGB>.self, ColorDistanceARGB.self, src, &trg, srcWidth, srcHeight, cfg, yFirst, yLast)
        case 4:
            return scaleImage(Scaler4x<ColorGradientARGB>.self, ColorDistanceARGB.self, src, &trg, srcWidth, srcHeight, cfg, yFirst, yLast)
        case 5:
            return scaleImage(Scaler5x<ColorGradientARGB>.self, ColorDistanceARGB.self, src, &trg, srcWidth, srcHeight, cfg, yFirst, yLast)
        case 6:
            return scaleImage(Scaler6x<ColorGradientARGB>.self, ColorDistanceARGB.self, src, &trg, srcWidth, srcHeight, cfg, yFirst, yLast)
        default:
            return
        }
    case .rgb:
        switch factor {
        case 2:
            return scaleImage(Scaler2x<ColorGradientRGB>.self, ColorDistanceRGB.self, src, &trg, srcWidth, srcHeight, cfg, yFirst, yLast)
        case 3:
            return scaleImage(Scaler3x<ColorGradientRGB>.self, ColorDistanceRGB.self, src, &trg, srcWidth, srcHeight, cfg, yFirst, yLast)
        case 4:
            return scaleImage(Scaler4x<ColorGradientRGB>.self, ColorDistanceRGB.self, src, &trg, srcWidth, srcHeight, cfg, yFirst, yLast)
        case 5:
            return scaleImage(Scaler5x<ColorGradientRGB>.self, ColorDistanceRGB.self, src, &trg, srcWidth, srcHeight, cfg, yFirst, yLast)
        case 6:
            return scaleImage(Scaler6x<ColorGradientRGB>.self, ColorDistanceRGB.self, src, &trg, srcWidth, srcHeight, cfg, yFirst, yLast)
        default:
            return
        }
    }
}

func scale(_ factor: UInt, _ src: [UInt32], _ trg: inout [UInt32], _ srcWidth:Int, _ srcHeight:Int, _ colFmt:ColorFormat, _ cfg:ScalerCfg, _ yFirst:Int = 0, _ yLast:Int = Int.max) {
    switch colFmt {
    case .argb:
        switch factor {
        case 2:
            return scaleImage(Scaler2x<ColorGradientARGB>.self, ColorDistanceARGB.self, src, &trg, srcWidth, srcHeight, cfg, yFirst, yLast)
        case 3:
            return scaleImage(Scaler3x<ColorGradientARGB>.self, ColorDistanceARGB.self, src, &trg, srcWidth, srcHeight, cfg, yFirst, yLast)
        case 4:
            return scaleImage(Scaler4x<ColorGradientARGB>.self, ColorDistanceARGB.self, src, &trg, srcWidth, srcHeight, cfg, yFirst, yLast)
        case 5:
            return scaleImage(Scaler5x<ColorGradientARGB>.self, ColorDistanceARGB.self, src, &trg, srcWidth, srcHeight, cfg, yFirst, yLast)
        case 6:
        return scaleImage(Scaler6x<ColorGradientARGB>.self, ColorDistanceARGB.self, src, &trg, srcWidth, srcHeight, cfg, yFirst, yLast)
        default:
            return
        }
    case .rgb:
        switch factor {
        case 2:
            return scaleImage(Scaler2x<ColorGradientRGB>.self, ColorDistanceRGB.self, src, &trg, srcWidth, srcHeight, cfg, yFirst, yLast)
        case 3:
            return scaleImage(Scaler3x<ColorGradientRGB>.self, ColorDistanceRGB.self, src, &trg, srcWidth, srcHeight, cfg, yFirst, yLast)
        case 4:
            return scaleImage(Scaler4x<ColorGradientRGB>.self, ColorDistanceRGB.self, src, &trg, srcWidth, srcHeight, cfg, yFirst, yLast)
        case 5:
            return scaleImage(Scaler5x<ColorGradientRGB>.self, ColorDistanceRGB.self, src, &trg, srcWidth, srcHeight, cfg, yFirst, yLast)
        case 6:
            return scaleImage(Scaler6x<ColorGradientRGB>.self, ColorDistanceRGB.self, src, &trg, srcWidth, srcHeight, cfg, yFirst, yLast)
        default:
            return
        }
    }
}

func equalColorTest(_ col1:UInt32, _ col2:UInt32, _ colFmt: ColorFormat, _ luminanceWeight: Double, _ equalColorTolerance: Double) -> Bool {
    switch colFmt {
    case .argb:
        return ColorDistanceARGB.dist(col1, col2, luminanceWeight) < equalColorTolerance
    case .rgb:
        return ColorDistanceRGB.dist(col1, col2, luminanceWeight) < equalColorTolerance
    }
}
