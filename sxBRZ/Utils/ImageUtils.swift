//
//  ImageUtils.swift
//  sxBRZ
//
//  Created by Robert Armenski on 04.26.16.
//

import Foundation

func createARGBBitmapContext(_ imageRef: CGImage) -> CGContext! {
    let pixelWidth = imageRef.width
    let pixelHeight = imageRef.height
    let bitmapBytesPerRow = (pixelWidth * 4)
    let bitmapByteCount = (bitmapBytesPerRow * pixelHeight)

    let colorSpace: CGColorSpace = CGColorSpaceCreateDeviceRGB()

    let bitmapData: UnsafeMutableRawPointer? = malloc(bitmapByteCount)
    if bitmapData == nil {
        return nil
    }
    let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue)
    return CGContext(data: bitmapData,
                     width: pixelWidth, height: pixelHeight,
                     bitsPerComponent: 8,
                     bytesPerRow: bitmapBytesPerRow,
                     space: colorSpace,
                     bitmapInfo: bitmapInfo.rawValue)!
}

func manipulatePixel(_ imageRef: CGImage) -> CGImage? {
    let context = createARGBBitmapContext(imageRef)
    let width = imageRef.width
    let height = imageRef.height
    let rect = CGRect(x: 0, y: 0, width: CGFloat(width), height: CGFloat(height))
    let bitmapBytesPerRow = Int(width) * 4

    //Clear the context
    context?.clear(rect)

    // Draw the image to the bitmap context. Once we draw, the memory
    // allocated for the context for rendering will then contain the
    // raw image data in the specified color space.
    context?.draw(imageRef, in: rect)

    let data: UnsafeMutableRawPointer = context!.data!
    let dataType = data.assumingMemoryBound(to: UInt32.self)
    // let dataType = UnsafeMutablePointer<UInt32>(data)
    // let dataType = UnsafeMutablePointer<UInt8>(data)

    for y in 0 ..< width {
        for x in (height - 20) ..< height {
            // If dataType == UInt32
            let offset = (width * x) + y
            // If dataType == UInt8
            // let offset = 4*((width * x) + y)

            let a: UInt32 = 255
            let r: UInt32 = 0
            let g: UInt32 = 255
            let b: UInt32 = 0

            // dataType[offset] = a
            // dataType[offset + 1] = r
            // dataType[offset + 2] = g
            // dataType[offset + 3] = b

            dataType[offset] = (b << 24) | (g << 16) | (r << 8) | a
        }
    }
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue)
    let contextRef = CGContext(data: data,
                               width: width, height: height,
                               bitsPerComponent: 8,
                               bytesPerRow: bitmapBytesPerRow,
                               space: colorSpace,
                               bitmapInfo: bitmapInfo.rawValue)
    let imageRef = contextRef?.makeImage()
    // let imageRef = CGBitmapContextCreateImage(context)
    free(data)
    return imageRef
}

func getImageData(_ imageRef: CGImage) -> [UInt32] {
    let context = createARGBBitmapContext(imageRef)
    let width = imageRef.width
    let height = imageRef.height
    let rect = CGRect(x: 0, y: 0, width: CGFloat(width), height: CGFloat(height))

    context?.clear(rect)
    context?.draw(imageRef, in: rect)

    let data: UnsafeMutableRawPointer = context!.data!
    let dataType = data.assumingMemoryBound(to: UInt8.self)
    // let dataType = UnsafeMutablePointer<UInt8>(data)
    var ret = [UInt32](repeating: 0, count: width * height)

    for y in 0 ..< width {
        for x in 0 ..< height {
            let offset = 4 * ((width * x) + y)

            let a = UInt32(dataType[offset])
            let r = UInt32(dataType[offset + 1])
            let g = UInt32(dataType[offset + 2])
            let b = UInt32(dataType[offset + 3])

            ret[x * width + y] = (a << 24) | (r << 16) | (g << 8) | b
        }
    }
    free(data)
    return ret
}
