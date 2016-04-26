//
// Created by T!T@N on 04.22.16.
// Copyright (c) 2016 TitanTech. All rights reserved.
//

import Foundation

func getByte(N: UInt32, val: UInt32) -> CUnsignedChar {
    return CUnsignedChar((val >> (8 * N)) & 0xff)
}
func getAlpha(pix: UInt32) -> CUnsignedChar {
    return getByte(3, val: pix)
}
func getRed(pix: UInt32) -> CUnsignedChar {
    return getByte(2, val: pix)
}
func getGreen(pix: UInt32) -> CUnsignedChar {
    return getByte(1, val: pix)
}
func getBlue(pix: UInt32) -> CUnsignedChar {
    return getByte(0, val: pix)
}

func makePixel(r: CUnsignedChar, _ g: CUnsignedChar, _ b: CUnsignedChar) -> UInt32 {
    return (UInt32(r) << 16) | (UInt32(g) << 8) | UInt32(b)
}

func makePixel(a: CUnsignedChar, _ r: CUnsignedChar, _ g: CUnsignedChar, _ b: CUnsignedChar) -> UInt32 {
    return (UInt32(a) << 24) | (UInt32(r) << 16) | (UInt32(g) << 8) | UInt32(b)
}

func gradientRGB(M: UInt32, _ N: UInt32, _ pixFront: UInt32, _ pixBack: UInt32) -> UInt32 {
    assert(0 < M && M < N && N <= 1000, "")

    func calcColor(colFront: CUnsignedChar, _ colBack: CUnsignedChar) -> CUnsignedChar {
        return CUnsignedChar((UInt32(colFront) * M + UInt32(colBack) * (N - M)) / N);
    }
    return makePixel(
            calcColor(getRed  (pixFront), getRed  (pixBack)),
            calcColor(getGreen(pixFront), getGreen(pixBack)),
            calcColor(getBlue (pixFront), getBlue (pixBack))
    );
}
func gradientARGB(M: UInt32, _ N: UInt32, _ pixFront: UInt32, _ pixBack: UInt32) -> UInt32 {
    assert(0 < M && M < N && N <= 1000, "")

    var weightFront:UInt32 = UInt32(getAlpha(pixFront)) * M
    var weightBack:UInt32 = UInt32(getAlpha(pixBack)) * (N - M)
    var weightSum:UInt32 = weightFront + weightBack
    if weightSum == 0 {
        return 0;
    }

    func calcColor(colFront: CUnsignedChar, _ colBack: CUnsignedChar) -> CUnsignedChar {
        return CUnsignedChar((UInt32(colFront) * weightFront + UInt32(colBack) * weightBack) / weightSum);
    }
    return makePixel(
            CUnsignedChar(weightSum / N),
            calcColor(getRed  (pixFront), getRed  (pixBack)),
            calcColor(getGreen(pixFront), getGreen(pixBack)),
            calcColor(getBlue (pixFront), getBlue (pixBack))
    );
}

func byteAdvance(ptr: UnsafeMutablePointer<UInt32>, _ bytes:Int) -> UnsafeMutablePointer<UInt32> {
    let tmpPtr = UnsafeMutablePointer<CUnsignedChar>(ptr)
    return UnsafeMutablePointer<UInt32>(tmpPtr + bytes)
}

// Fill block  with the given color
func fillBlock(trg: UnsafeMutablePointer<UInt32>, _ pitch:Int, _ col: UInt32, _ blockWidth:Int, _ blockHeight: Int) {
    var trgPt = UnsafeMutablePointer<UInt32>(trg)
    // for y in 0..<blockHeight {
    for y in 0..<blockHeight {
        for x in 0..<blockWidth {
            trgPt[x] = col
        }
        // trgPt += pitch
        trgPt = byteAdvance(trgPt, pitch)
    }
}
func fillBlock(trg: UnsafeMutablePointer<UInt32>, _ pitch:Int, _ col: UInt32, _ n:Int) {
    fillBlock(trg, pitch, col, n, n)
}

func distRGB(pix1: UInt32, _ pix2: UInt32) -> Double
{
    let r_diff = Double(Int(getRed  (pix1)) - Int(getRed  (pix2)))
    let g_diff = Double(Int(getGreen(pix1)) - Int(getGreen(pix2)))
    let b_diff = Double(Int(getBlue (pix1)) - Int(getBlue (pix2)))

    //euclidean RGB distance
    return sqrt(pow(r_diff, 2) + pow(g_diff, 2) + pow(b_diff, 2))
}

func preProcessCorners(colorDistance:ColorDistance.Type, inout _ ker:Kernel_4x4, inout _ cfg:ScalerCfg) -> BlendResult
{
    //result: F, G, J, K corners of "GradientType"
    var result = BlendResult()

    if ((ker.f == ker.g &&
         ker.j == ker.k) ||
        (ker.f == ker.j &&
         ker.g == ker.k)) {
        return result;
    }

    func dist(pix1:UInt32, _ pix2: UInt32) -> Double {
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
            result.blend_f = dominantGradient ? BlendType.BLEND_DOMINANT : BlendType.BLEND_NORMAL
        }
        if ker.k != ker.j && ker.k != ker.g {
            result.blend_k = dominantGradient ? BlendType.BLEND_DOMINANT : BlendType.BLEND_NORMAL
        }
    }
    else if fk < jg
    {
        let dominantGradient:Bool = cfg.dominantDirectionThreshold * fk < jg
        if ker.j != ker.f && ker.j != ker.k {
            result.blend_j = dominantGradient ? BlendType.BLEND_DOMINANT : BlendType.BLEND_NORMAL
        }
        if ker.g != ker.f && ker.g != ker.k {
            result.blend_g = dominantGradient ? BlendType.BLEND_DOMINANT : BlendType.BLEND_NORMAL
        }
    }
    return result;
}

//template <RotationDegree rotDeg> uint32_t inline get_##x(const Kernel_3x3& ker) { return ker.x; }
func get_a(rotDeg: RotationDegree, inout _ ker:Kernel_3x3) -> UInt32 { return ker.a }
func get_b(rotDeg: RotationDegree, inout _ ker:Kernel_3x3) -> UInt32 { return ker.b }
func get_c(rotDeg: RotationDegree, inout _ ker:Kernel_3x3) -> UInt32 { return ker.c }
func get_d(rotDeg: RotationDegree, inout _ ker:Kernel_3x3) -> UInt32 { return ker.d }
func get_e(rotDeg: RotationDegree, inout _ ker:Kernel_3x3) -> UInt32 { return ker.e }
func get_f(rotDeg: RotationDegree, inout _ ker:Kernel_3x3) -> UInt32 { return ker.f }
func get_g(rotDeg: RotationDegree, inout _ ker:Kernel_3x3) -> UInt32 { return ker.g }
func get_h(rotDeg: RotationDegree, inout _ ker:Kernel_3x3) -> UInt32 { return ker.h }
func get_i(rotDeg: RotationDegree, inout _ ker:Kernel_3x3) -> UInt32 { return ker.i }

func getTopL   (b:CUnsignedChar) -> BlendType { return BlendType(rawValue: (0x3 & b))! }
func getTopR   (b:CUnsignedChar) -> BlendType { return BlendType(rawValue: (0x3 & (b >> 2)))! }
func getBottomR   (b:CUnsignedChar) -> BlendType { return BlendType(rawValue: (0x3 & (b >> 4)))! }
func getBottomL   (b:CUnsignedChar) -> BlendType { return BlendType(rawValue: (0x3 & (b >> 6)))! }

//buffer is assumed to be initialized before preprocessing!
func setTopL (inout b:CUnsignedChar, _ bt:BlendType) { b |= bt.rawValue }
func setTopR (inout b:CUnsignedChar, _ bt:BlendType) { b |= (bt.rawValue << 2) }
func setBottomR (inout b:CUnsignedChar, _ bt:BlendType) { b |= (bt.rawValue << 4) }
func setBottomL (inout b:CUnsignedChar, _ bt:BlendType) { b |= (bt.rawValue << 6) }

func blendingNeeded(b:CUnsignedChar) -> Bool { return b != 0 }

func rotateBlendInfo(rotDeg:RotationDegree, _ b:CUnsignedChar) -> CUnsignedChar {
    switch rotDeg {
    case .ROT_0:
        return b
    case .ROT_90:
        return ((b << 2) | (b >> 6)) & 0xff
    case .ROT_180:
        return ((b << 4) | (b >> 4)) & 0xff
    case .ROT_270:
        return ((b << 6) | (b >> 2)) & 0xff
    }
}

#if DEBUG
    let breakIntoDebugger = false
#endif

func blendPixel(scaler:Scaler.Type, _ colorDistance:ColorDistance.Type, _ rotDeg:RotationDegree, inout _ ker:Kernel_3x3, _ target: UnsafeMutablePointer<UInt32>, _ trgWidth: Int, _ blendInfo:CUnsignedChar, inout _ cfg:ScalerCfg) {
    var a = get_a(rotDeg, &ker)
    var b = get_b(rotDeg, &ker)
    var c = get_c(rotDeg, &ker)
    var d = get_d(rotDeg, &ker)
    var e = get_e(rotDeg, &ker)
    var f = get_f(rotDeg, &ker)
    var g = get_g(rotDeg, &ker)
    var h = get_h(rotDeg, &ker)
    var i = get_i(rotDeg, &ker)

    var blend = rotateBlendInfo(rotDeg, blendInfo)
    if getBottomR(blend).rawValue >= BlendType.BLEND_NORMAL.rawValue {
        func eq(pix1:UInt32, _ pix2:UInt32) -> Bool {
            return colorDistance.dist(pix1, pix2, cfg.luminanceWeight) < cfg.equalColorTolerance
        }
        func dist(pix1:UInt32, _ pix2:UInt32) -> Double {
            return colorDistance.dist(pix1, pix2, cfg.luminanceWeight)
        }

        let doLineBlend:Bool =  {
            if getBottomR(blend).rawValue >= BlendType.BLEND_DOMINANT.rawValue {
                return true;
            }
            //make sure there is no second blending in an adjacent rotation for this pixel: handles insular pixels, mario eyes
            if getTopR(blend) != BlendType.BLEND_NONE && !eq(e, g) {
                return false;
            }
            if getBottomL(blend) != BlendType.BLEND_NONE && !eq(e, c) {
                return false;
            }

            //no full blending for L-shapes; blend corner only (handles "mario mushroom eyes")
            if !eq(e, i) && eq(g, h) && eq(h, i) && eq(i, f) && eq(f, c) {
                return false;
            }

            return true;
        }()

        //choose most similar color
        let px:UInt32 = dist(e, f) <= dist(e, h) ? f : h
        var out = OutputMatrix(UInt(scaler.scale), rotDeg, target, trgWidth)

        if doLineBlend {
            let fg = dist(f, g)
            let hc = dist(h, c)
            let haveShallowLine:Bool = cfg.steepDirectionThreshold * fg <= hc && e != g && d != g
            let haveSteepLine:Bool   = cfg.steepDirectionThreshold * hc <= fg && e != c && b != c

            if haveShallowLine {
                if haveSteepLine {
                    scaler.blendLineSteepAndShallow(px, &out)
                }
                else {
                    scaler.blendLineShallow(px, &out)
                }
            }
            else {
                if haveSteepLine {
                    scaler.blendLineSteep(px, &out)
                }
                else {
                    scaler.blendLineDiagonal(px, &out)
                }
            }
        }
        else {
            scaler.blendCorner(px, &out)
        }
    }
}

func scaleImage(scaler:Scaler.Type, _ colorDistance:ColorDistance.Type, _ src: UnsafeMutablePointer<UInt32>, _ trg: UnsafeMutablePointer<UInt32>, _ srcWidth:Int, _ srcHeight:Int, inout _ cfg:ScalerCfg, _ yFirst:Int, _ yLast:Int) {

    let yFirst = max(yFirst, 0)
    let yLast = min(yLast, srcHeight)
    if yFirst >= yLast || srcWidth <= 0 {
        return;
    }

    let trgWidth = srcWidth * scaler.scale
    //"use" space at the end of the image as temporary buffer for "on the fly preprocessing": we even could use larger area of
    //"sizeof(uint32_t) * srcWidth * (yLast - yFirst)" bytes without risk of accidental overwriting before accessing
    let bufferSize = srcWidth

    let trgChar = UnsafeMutablePointer<CUnsignedChar>(trg + yLast * scaler.scale * trgWidth)
    let preProcBuffer:UnsafeMutablePointer<CUnsignedChar> = trgChar - bufferSize
    //    std::fill(preProcBuffer, preProcBuffer + bufferSize, 0);
    for i in 0..<bufferSize {
        preProcBuffer[i] = 0
    }
    assert(BlendType.BLEND_NONE.rawValue == 0, "Blend NONE is not 0")
    //initialize preprocessing buffer for first row of current stripe: detect upper left and right corner blending
    //this cannot be optimized for adjacent processing stripes; we must not allow for a memory race condition!
    if (yFirst > 0)
    {
        let y = yFirst - 1

        let s_m1:UnsafeMutablePointer<UInt32> = src + srcWidth * max(y-1, 0)
        let s_0:UnsafeMutablePointer<UInt32>  = src + srcWidth * y
        let s_p1:UnsafeMutablePointer<UInt32> = src + srcWidth * min(y+1, srcHeight-1)
        let s_p2:UnsafeMutablePointer<UInt32> = src + srcWidth * min(y+2, srcHeight-1)

        for x in 0..<srcWidth {
            let x_m1 = max(x-1, 0)
            let x_p1 = min(x+1, srcWidth-1)
            let x_p2 = min(x+2, srcWidth-1)

            var ker = Kernel_4x4(
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

            let res = preProcessCorners(colorDistance, &ker, &cfg)
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
        var out:UnsafeMutablePointer<UInt32> = trg + scaler.scale * y * trgWidth

        let s_m1:UnsafeMutablePointer<UInt32> = src + srcWidth * max(y-1,0)
        let s_0:UnsafeMutablePointer<UInt32>  = src + srcWidth * y
        let s_p1:UnsafeMutablePointer<UInt32> = src + srcWidth * min(y+1, srcHeight-1)
        let s_p2:UnsafeMutablePointer<UInt32> = src + srcWidth * min(y+2, srcHeight-1)

        var blend_xy1:CUnsignedChar = 0 //corner blending for current (x, y + 1) position
        for x in 0..<srcWidth {
            //all those bounds checks have only insignificant impact on performance!
            let x_m1 = max(x-1, 0)
            let x_p1 = min(x+1, srcWidth-1)
            let x_p2 = min(x+2, srcWidth-1)

            var ker4 = Kernel_4x4(
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
            var blend_xy:CUnsignedChar = 0; //for current (x, y) position
            let res = preProcessCorners(colorDistance, &ker4, &cfg)
            /*
             preprocessing blend result:
             ---------
             | F | G |   //evalute corner between F, G, J, K
             ----|---|   //current input pixel is at position F
             | J | K |
             ---------
             */
            blend_xy = preProcBuffer[x]
            //all four corners of (x, y) have been determined at this point due to processing sequence!
            setBottomR(&blend_xy, res.blend_f)

            setTopR(&blend_xy1, res.blend_j) //set 2nd known corner for (x, y + 1)
            preProcBuffer[x] = blend_xy1 //store on current buffer position for use on next row

            blend_xy1 = 0
            //set 1st known corner for (x + 1, y + 1) and buffer for use on next column
            setTopL(&blend_xy1, res.blend_k)

            if (x + 1 < bufferSize) {
                //set 3rd known corner for (x + 1, y)
                setBottomL(&preProcBuffer[x + 1], res.blend_g);
            }

            //fill block of size scale * scale with the given color
            //place *after* preprocessing step, to not overwrite the results while processing the the last pixel!

            // with byteAdvance
            fillBlock(out, trgWidth * sizeof(UInt32), ker4.f, scaler.scale)
            // fillBlock(out, trgWidth, ker4.f, scaler.scale)

            //blend four corners of current pixel
            if blendingNeeded(blend_xy) { //good 5% perf-improvement
                var ker3 = Kernel_3x3(
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
                blendPixel(scaler, colorDistance, RotationDegree.ROT_0, &ker3, out, trgWidth, blend_xy, &cfg)
                blendPixel(scaler, colorDistance, RotationDegree.ROT_90, &ker3, out, trgWidth, blend_xy, &cfg)
                blendPixel(scaler, colorDistance, RotationDegree.ROT_180, &ker3, out, trgWidth, blend_xy, &cfg)
                blendPixel(scaler, colorDistance, RotationDegree.ROT_270, &ker3, out, trgWidth, blend_xy, &cfg)
            }
            out += scaler.scale
        }
    }
}


func scale(factor: UInt, _ src: UnsafeMutablePointer<UInt32>, _ trg: UnsafeMutablePointer<UInt32>, _ srcWidth:Int, _ srcHeight:Int, _ colFmt:ColorFormat, inout _ cfg:ScalerCfg, _ yFirst:Int = 0, _ yLast:Int = Int.max) {
    switch colFmt {
    case .ARGB:
        switch factor {
        case 2:
            return scaleImage(Scaler2x<ColorGradientARGB>.self, ColorDistanceARGB.self, src, trg, srcWidth, srcHeight, &cfg, yFirst, yLast)
        case 3:
            return scaleImage(Scaler3x<ColorGradientARGB>.self, ColorDistanceARGB.self, src, trg, srcWidth, srcHeight, &cfg, yFirst, yLast)
        case 4:
            return scaleImage(Scaler4x<ColorGradientARGB>.self, ColorDistanceARGB.self, src, trg, srcWidth, srcHeight, &cfg, yFirst, yLast)
        case 5:
            return scaleImage(Scaler5x<ColorGradientARGB>.self, ColorDistanceARGB.self, src, trg, srcWidth, srcHeight, &cfg, yFirst, yLast)
        case 6:
            return scaleImage(Scaler6x<ColorGradientARGB>.self, ColorDistanceARGB.self, src, trg, srcWidth, srcHeight, &cfg, yFirst, yLast)
        default:
            return;
        }
    case .RGB:
        switch factor {
        case 2:
            return scaleImage(Scaler2x<ColorGradientRGB>.self, ColorDistanceRGB.self, src, trg, srcWidth, srcHeight, &cfg, yFirst, yLast)
        case 3:
            return scaleImage(Scaler3x<ColorGradientRGB>.self, ColorDistanceRGB.self, src, trg, srcWidth, srcHeight, &cfg, yFirst, yLast)
        case 4:
            return scaleImage(Scaler4x<ColorGradientRGB>.self, ColorDistanceRGB.self, src, trg, srcWidth, srcHeight, &cfg, yFirst, yLast)
        case 5:
            return scaleImage(Scaler5x<ColorGradientRGB>.self, ColorDistanceRGB.self, src, trg, srcWidth, srcHeight, &cfg, yFirst, yLast)
        case 6:
            return scaleImage(Scaler6x<ColorGradientRGB>.self, ColorDistanceRGB.self, src, trg, srcWidth, srcHeight, &cfg, yFirst, yLast)
        default:
            return;
        }
    }
}


func equalColorTest(col1:UInt32, _ col2:UInt32, _ colFmt: ColorFormat, _ luminanceWeight: Double, _ equalColorTolerance: Double) -> Bool {
    switch colFmt {
    case .ARGB:
        return ColorDistanceARGB.dist(col1, col2, luminanceWeight) < equalColorTolerance
    case .RGB:
        return ColorDistanceRGB.dist(col1, col2, luminanceWeight) < equalColorTolerance
    }
}
