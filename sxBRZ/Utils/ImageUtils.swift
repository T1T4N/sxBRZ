//
//  ImageUtils.swift
//  sxBRZ
//
//  Created by Robert Armenski on 04.26.16.
//

import Foundation

func createARGBBitmapContext(imageRef: CGImageRef) -> CGContextRef! {
    let pixelWidth = CGImageGetWidth(imageRef);
    let pixelHeight = CGImageGetHeight(imageRef);
    let bitmapBytesPerRow = (pixelWidth * 4)
    let bitmapByteCount = (bitmapBytesPerRow * pixelHeight)

    let colorSpace: CGColorSpace = CGColorSpaceCreateDeviceRGB()!

    let bitmapData: UnsafeMutablePointer<Void> = malloc(bitmapByteCount)
    if bitmapData == nil {
        return nil
    }
    let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.PremultipliedFirst.rawValue)
    let context: CGContextRef = CGBitmapContextCreate(bitmapData, pixelWidth, pixelHeight, 8, bitmapBytesPerRow, colorSpace, bitmapInfo.rawValue)!
    return context
}

func manipulatePixel(imageRef: CGImageRef) -> CGImageRef? {
    let context = createARGBBitmapContext(imageRef)
    let width = CGImageGetWidth(imageRef)
    let height = CGImageGetHeight(imageRef)
    let rect = CGRectMake(0, 0, CGFloat(width), CGFloat(height))
    let bitmapBytesPerRow = Int(width) * 4

    //Clear the context
    CGContextClearRect(context, rect)

    // Draw the image to the bitmap context. Once we draw, the memory
    // allocated for the context for rendering will then contain the
    // raw image data in the specified color space.
    CGContextDrawImage(context, rect, imageRef)

    let data: UnsafeMutablePointer<Void> = CGBitmapContextGetData(context)
    let dataType = UnsafeMutablePointer<UInt32>(data)
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

            dataType[offset] = (b << 24) | (g << 16) | (r << 8) | a;
        }
    }
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.PremultipliedFirst.rawValue)
    let contextRef = CGBitmapContextCreate(data, width, height, 8, bitmapBytesPerRow, colorSpace, bitmapInfo.rawValue)
    let imageRef = CGBitmapContextCreateImage(contextRef)
    // let imageRef = CGBitmapContextCreateImage(context)
    free(data)
    return imageRef
}

func getImageData(imageRef: CGImageRef) -> [UInt32] {
    let context = createARGBBitmapContext(imageRef)
    let width = CGImageGetWidth(imageRef)
    let height = CGImageGetHeight(imageRef)
    let rect = CGRectMake(0, 0, CGFloat(width), CGFloat(height))

    CGContextClearRect(context, rect)
    CGContextDrawImage(context, rect, imageRef)

    let data: UnsafeMutablePointer<Void> = CGBitmapContextGetData(context)
    let dataType = UnsafeMutablePointer<UInt8>(data)
    var ret = [UInt32](count: width * height, repeatedValue: 0)

    for y in 0 ..< width {
        for x in 0 ..< height {
            let offset = 4 * ((width * x) + y)

            let a: UInt32 = UInt32(dataType[offset])
            let r: UInt32 = UInt32(dataType[offset + 1])
            let g: UInt32 = UInt32(dataType[offset + 2])
            let b: UInt32 = UInt32(dataType[offset + 3])

            ret[x * width + y] = (a << 24) | (r << 16) | (g << 8) | b;
        }
    }
    free(data)
    return ret
}