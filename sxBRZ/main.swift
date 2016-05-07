//
//  main.swift
//  sxBRZ
//
//  Created by T!T@N on 04.22.16.
//

import Foundation
import AppKit

func validScale(scale: String) -> Bool {
    switch scale {
    case "2":
        return true
    case "3":
        return true
    case "4":
        return true
    case "5":
        return true
    case "6":
        return true
    default:
        return false
    }
}

if Process.arguments.count < 4 {
    print("Usage: xbrz inputFile scaleFactor outputFile")
    print("inputFile is assumed to be in the Grayscale, RGB or RGBA color space")
    exit(EXIT_FAILURE)
}

let inPath = Process.arguments[1]
let requestedScale = Process.arguments[2]
let outPath = Process.arguments[3]

if !validScale(requestedScale) {
    print("Scale must be 2, 3, 4, 5 or 6")
    exit(EXIT_FAILURE)
}

let scaleFactor = Int(requestedScale)!
if let image = NSImage(contentsOfURL: NSURL(fileURLWithPath: inPath)) {
    print("Loading image from path: \(inPath)")
    if let cgRef = image.CGImageForProposedRect(nil, context: nil, hints: nil) {
        let width = CGImageGetWidth(cgRef)
        let height = CGImageGetHeight(cgRef)

        let outWidth = scaleFactor * width
        let outHeight = scaleFactor * height

        var p_raw = getImageData(cgRef)
        let rawpt = UnsafeMutablePointer<UInt32>(p_raw)

        var p_output = [UInt32](count: scaleFactor * scaleFactor * height * width, repeatedValue: 0)
        let outpt = UnsafeMutablePointer<UInt32>(p_output)

        // p_fin contains the data converted to ARGB
        var p_fin = [UInt32](count: scaleFactor * scaleFactor * height * width, repeatedValue: 0)
        let finpt = UnsafeMutablePointer<UInt32>(p_fin)

        var cfg = ScalerCfg()
        scale(UInt(scaleFactor), rawpt, outpt, width, height, ColorFormat.ARGB, &cfg)
//        xBRZC.scale(scaleFactor, source: rawpt, target: outpt, width: Int32(width), height: Int32(height), hasAlpha: true)

        // Convert RGBA to ARGB
        let convpt = UnsafeMutablePointer<UInt8>(outpt)
        for y in 0 ..< outWidth {
            for x in 0 ..< outHeight {
                let offset = 4 * (x * outWidth + y)

                let a: UInt32 = UInt32(convpt[offset])
                let r: UInt32 = UInt32(convpt[offset + 1])
                let g: UInt32 = UInt32(convpt[offset + 2])
                let b: UInt32 = UInt32(convpt[offset + 3])

                finpt[x * outWidth + y] = (a << 24) | (r << 16) | (g << 8) | b
            }
        }

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.PremultipliedFirst.rawValue)
        let modCont = CGBitmapContextCreate(UnsafeMutablePointer<Void>(finpt), outWidth, outHeight, 8, 4 * outWidth, colorSpace, bitmapInfo.rawValue)
        let modRef = CGBitmapContextCreateImage(modCont)

        let imgRep = NSBitmapImageRep(CGImage: modRef!)
        var data = imgRep.representationUsingType(NSBitmapImageFileType.NSBMPFileType, properties: [:])
        data?.writeToFile(outPath, atomically: false)
        print("Image successfully scaled")
    }

} else {
    print("Missing image at: \(inPath)")
    exit(EXIT_FAILURE)
}