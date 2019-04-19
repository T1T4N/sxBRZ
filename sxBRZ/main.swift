//
//  main.swift
//  sxBRZ
//
//  Created by T!T@N on 04.22.16.
//

import Foundation
import AppKit

func isValid(scale: String) -> Bool {
    switch scale {
    case "2", "3", "4", "5", "6":
        return true
    default:
        return false
    }
}

if CommandLine.arguments.count < 4 {
    print("Usage: xbrz inputFile scaleFactor outputFile")
    print("inputFile is assumed to be in the Grayscale, RGB or RGBA color space")
    exit(EXIT_FAILURE)
}

let inPath = CommandLine.arguments[1]
let requestedScale = CommandLine.arguments[2]
let outPath = CommandLine.arguments[3]

guard isValid(scale: requestedScale),
    let scaleFactor = Int(requestedScale) else {
        print("Scale must be 2, 3, 4, 5 or 6")
        exit(EXIT_FAILURE)
}

print("Loading image from path: \(inPath)")
guard let image = NSImage(contentsOf: URL(fileURLWithPath: inPath)),
    let cgRef = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
        print("Failed to load image")
        exit(EXIT_FAILURE)
}

let width = cgRef.width
let height = cgRef.height

let outWidth = scaleFactor * width
let outHeight = scaleFactor * height

var rawData = getImageData(cgRef)
let rawpt = UnsafeMutablePointer<UInt32>(mutating: rawData)

var p_output = [UInt32](repeating: 0, count: scaleFactor * scaleFactor * height * width)
var outpt = UnsafeMutablePointer<UInt32>(mutating: p_output)

// p_fin contains the data converted to ARGB
var p_fin = [UInt32](repeating: 0, count: scaleFactor * scaleFactor * height * width)
let finpt = UnsafeMutablePointer<UInt32>(mutating: p_fin)

var cfg = ScalerCfg()
scale(UInt(scaleFactor), rawpt, &outpt, width, height, ColorFormat.argb, cfg)
//scale(UInt(scaleFactor), p_raw, &p_output, width, height, ColorFormat.ARGB, cfg)
//xBRZC.scale(scaleFactor, source: rawpt, target: outpt, width: Int32(width), height: Int32(height), hasAlpha: true)

// Convert RGBA to ARGB
outpt.withMemoryRebound(to: UInt8.self, capacity: MemoryLayout.size(ofValue: p_output)) { convpt in
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
}

let colorSpace = CGColorSpaceCreateDeviceRGB()
let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue)
let modCont = CGContext(data: UnsafeMutableRawPointer(finpt), width: outWidth, height: outHeight, bitsPerComponent: 8, bytesPerRow: 4 * outWidth, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
let modRef = modCont?.makeImage()

let imgRep = NSBitmapImageRep(cgImage: modRef!)
var data = imgRep.representation(using: NSBitmapImageRep.FileType.bmp, properties: [:])

do {
    try data?.write(to: URL(fileURLWithPath: outPath), options: [])
    print("Image successfully scaled")
} catch {
    print("Failed to write output data: \(error)")
}
