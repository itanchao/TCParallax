//
//  UIImage+ImageEffects.swift
//  Parallaxscrollview
//
//  Created by tanchao on 16/4/20.
//  Copyright © 2016年 谈超. All rights reserved.
//

import UIKit
import Accelerate
extension UIImage{
    func applySubtleEffect() -> UIImage? {
        return applyBlurWithblurRadius(3, tintColor: UIColor(white: 1.0, alpha: 0.3), saturationDeltaFactor: 1.8, maskImage: nil)
    }
    func applyLightEffect() -> UIImage? {
        return applyBlurWithblurRadius(30, tintColor: UIColor(white: 1.0, alpha: 0.3), saturationDeltaFactor: 1.8, maskImage: nil)
    }
    func applyExtraLightEffect() -> UIImage? {
        return applyBlurWithblurRadius(20, tintColor: UIColor(white: 0.97, alpha: 0.82), saturationDeltaFactor: 1.8, maskImage: nil)
    }
    func applyDarkEffect() -> UIImage? {
        return applyBlurWithblurRadius(20, tintColor: UIColor(white: 0.11, alpha: 0.73), saturationDeltaFactor: 1.8, maskImage: nil)
    }
    func applyTintEffectWithColor(tintColor:UIColor) -> UIImage? {
        let EffectColorAlpha : CGFloat = 0.6
        var effectColor = tintColor
        let componentCount = CGColorGetNumberOfComponents(tintColor.CGColor)
        if componentCount == 2 {
            var b : CGFloat = 0
            if tintColor.getWhite(&b, alpha: UnsafeMutablePointer<CGFloat>.alloc(0)) {
                effectColor = UIColor(white: b, alpha: EffectColorAlpha)
            }
        }
        else{
            var r : CGFloat = 0
            var g : CGFloat = 0
            var b : CGFloat = 0
            if tintColor.getRed(&r, green: &g, blue: &b, alpha: UnsafeMutablePointer<CGFloat>.alloc(0)) {
                effectColor = UIColor(red: r, green: g, blue: b, alpha: EffectColorAlpha)
            }
        }
        return applyBlurWithblurRadius(10, tintColor: effectColor, saturationDeltaFactor: -1.0, maskImage: nil)
    }
    func applyBlurWithblurRadius(blurRadius:CGFloat,tintColor:UIColor?,saturationDeltaFactor:CGFloat,maskImage:UIImage?) -> UIImage? {
        if size.width<1 || size.height<1 {
            print("*** error: invalid size: (\(size.width) x \(size.height)). Both dimensions must be >= 1: \(self)")
            return nil
        }
        if (CGImage == nil) {
            print("*** error: image must be backed by a CGImage: \(self)")
            return nil
        }
        if(maskImage != nil) && (maskImage!.CGImage == nil) {
            print("*** error: maskImage must be backed by a CGImage: \(self)")
            return nil
        }
        let imageRect = CGRect(origin: CGPointZero, size: size)
        var effectImage = self
        let hasBlur = blurRadius > 0
        let hasSaturationChange = fabs(saturationDeltaFactor-1) > 0
        if hasBlur || hasSaturationChange {
            UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.mainScreen().scale)
            let effectInContext = UIGraphicsGetCurrentContext()
            CGContextScaleCTM(effectInContext, 1, -1)
            CGContextTranslateCTM(effectInContext, 0, -size.height)
            CGContextDrawImage(effectInContext, imageRect, CGImage)
            var effectInBuffer : vImage_Buffer = vImage_Buffer()
            effectInBuffer.data = CGBitmapContextGetData(effectInContext)
            effectInBuffer.width = UInt(CGBitmapContextGetWidth(effectInContext))
            effectInBuffer.height = UInt(CGBitmapContextGetHeight(effectInContext))
            effectInBuffer.rowBytes = CGBitmapContextGetBytesPerRow(effectInContext)
            UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.mainScreen().scale)
            let effectOutContext = UIGraphicsGetCurrentContext()
            var effectOutBuffer = vImage_Buffer()
            effectOutBuffer.data = CGBitmapContextGetData(effectOutContext)
            effectOutBuffer.width = UInt(CGBitmapContextGetWidth(effectOutContext))
            effectOutBuffer.height = UInt(CGBitmapContextGetHeight(effectOutContext))
            effectOutBuffer.rowBytes = CGBitmapContextGetBytesPerRow(effectOutContext)
            if hasBlur {
                let inputRadius = blurRadius * UIScreen.mainScreen().scale
                var radius = UInt32(floor(Double(inputRadius) * 3 * sqrt(2 * M_PI) / 4+0.5))
                if radius % 2 != 1 {
                    radius += 1
                }
                vImageBoxConvolve_ARGB8888(&effectInBuffer, &effectOutBuffer, nil, 0, 0, radius, radius, UnsafePointer<UInt8>(bitPattern: 0), UInt32(kvImageEdgeExtend))
                vImageBoxConvolve_ARGB8888(&effectOutBuffer, &effectInBuffer, nil, 0, 0, radius, radius, UnsafePointer<UInt8>(bitPattern: 0), UInt32(kvImageEdgeExtend))
                vImageBoxConvolve_ARGB8888(&effectInBuffer, &effectOutBuffer, nil, 0, 0, radius, radius, UnsafePointer<UInt8>(bitPattern: 0), UInt32(kvImageEdgeExtend))
            }
            var effectImageBuffersAreSwapped = false
            if hasSaturationChange {
                let s = saturationDeltaFactor
                let floatingPointSaturationMatrix = [
                    0.0722 + 0.9278 * s,  0.0722 - 0.0722 * s,  0.0722 - 0.0722 * s,  0,
                    0.7152 - 0.7152 * s,  0.7152 + 0.2848 * s,  0.7152 - 0.7152 * s,  0,
                    0.2126 - 0.2126 * s,  0.2126 - 0.2126 * s,  0.2126 + 0.7873 * s,  0,
                    0,                    0,                    0,  1,
                ]
                let divisor : Int32 = 256
                sizeofValue(floatingPointSaturationMatrix)/sizeofValue(floatingPointSaturationMatrix.first)
                let matrixSize = sizeofValue(floatingPointSaturationMatrix)/sizeofValue(floatingPointSaturationMatrix.first)
                var saturationMatrix : [__int16_t] = Array(count: matrixSize, repeatedValue: 0)
                for i in 0 ... matrixSize {
                    saturationMatrix[i] = __int16_t(Int32(roundf(Float(floatingPointSaturationMatrix[i]))) * divisor)
                }
                if hasBlur {
                    vImageMatrixMultiply_ARGB8888(&effectOutBuffer, &effectInBuffer, saturationMatrix, divisor, nil, nil, UInt32(kvImageNoFlags))
                    effectImageBuffersAreSwapped = true
                }
                else{
                    vImageMatrixMultiply_ARGB8888(&effectInBuffer, &effectOutBuffer, saturationMatrix, divisor, nil, nil, UInt32(kvImageNoFlags))
                }
            }
            if !effectImageBuffersAreSwapped {
                effectImage = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
            }
            if effectImageBuffersAreSwapped {
                effectImage = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
            }
        }
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.mainScreen().scale)
        let outputContext = UIGraphicsGetCurrentContext()
        CGContextScaleCTM(outputContext, 1.0, -1.0)
        CGContextTranslateCTM(outputContext, 0, -size.height)
        // Draw base image.
        CGContextDrawImage(outputContext, imageRect, CGImage)
        // Draw effect image.
        if (hasBlur) {
            CGContextSaveGState(outputContext)
            if ((maskImage) != nil) {
                CGContextClipToMask(outputContext, imageRect, maskImage!.CGImage)
            }
            CGContextDrawImage(outputContext, imageRect, effectImage.CGImage)
            CGContextRestoreGState(outputContext)
        }
        // Add in color tint.
        if ((tintColor) != nil) {
            CGContextSaveGState(outputContext)
            CGContextSetFillColorWithColor(outputContext, tintColor!.CGColor)
            CGContextFillRect(outputContext, imageRect)
            CGContextRestoreGState(outputContext)
        }
        // Output image is ready.
        let outputImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return outputImage
    }
    
}


