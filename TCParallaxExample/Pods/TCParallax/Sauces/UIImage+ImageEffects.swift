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
        return applyBlurWithblurRadius(blurRadius: 3, tintColor: UIColor(white: 1.0, alpha: 0.3), saturationDeltaFactor: 1.8, maskImage: nil)
    }
    func applyLightEffect() -> UIImage? {
        return applyBlurWithblurRadius(blurRadius: 30, tintColor: UIColor(white: 1.0, alpha: 0.3), saturationDeltaFactor: 1.8, maskImage: nil)
    }
    func applyExtraLightEffect() -> UIImage? {
        return applyBlurWithblurRadius(blurRadius: 20, tintColor: UIColor(white: 0.97, alpha: 0.82), saturationDeltaFactor: 1.8, maskImage: nil)
    }
    func applyDarkEffect() -> UIImage? {
        return applyBlurWithblurRadius(blurRadius: 20, tintColor: UIColor(white: 0.11, alpha: 0.73), saturationDeltaFactor: 1.8, maskImage: nil)
    }
    func applyTintEffectWithColor(tintColor:UIColor) -> UIImage? {
        let EffectColorAlpha : CGFloat = 0.6
        var effectColor = tintColor
        let componentCount = tintColor.cgColor.numberOfComponents
        if componentCount == 2 {
            var b : CGFloat = 0
            if tintColor.getWhite(&b, alpha: UnsafeMutablePointer<CGFloat>.allocate(capacity: 0)) {
                effectColor = UIColor(white: b, alpha: EffectColorAlpha)
            }
        }
        else{
            var r : CGFloat = 0
            var g : CGFloat = 0
            var b : CGFloat = 0
            if tintColor.getRed(&r, green: &g, blue: &b, alpha: UnsafeMutablePointer<CGFloat>.allocate(capacity: 0)) {
                effectColor = UIColor(red: r, green: g, blue: b, alpha: EffectColorAlpha)
            }
        }
        return applyBlurWithblurRadius(blurRadius: 10, tintColor: effectColor, saturationDeltaFactor: -1.0, maskImage: nil)
    }
    func applyBlurWithblurRadius(blurRadius:CGFloat,tintColor:UIColor?,saturationDeltaFactor:CGFloat,maskImage:UIImage?) -> UIImage? {
        if size.width<1 || size.height<1 {
            print("*** error: invalid size: (\(size.width) x \(size.height)). Both dimensions must be >= 1: \(self)")
            return nil
        }
        if (cgImage == nil) {
            print("*** error: image must be backed by a CGImage: \(self)")
            return nil
        }
        if(maskImage != nil) && (maskImage!.cgImage == nil) {
            print("*** error: maskImage must be backed by a CGImage: \(self)")
            return nil
        }
        let imageRect = CGRect(origin: CGPoint(x: 0, y: 0), size: size)
        var effectImage = self
        let hasBlur = blurRadius > 0
        let hasSaturationChange = fabs(saturationDeltaFactor-1) > 0
        if hasBlur || hasSaturationChange {
            UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
            let effectInContext = UIGraphicsGetCurrentContext()
            effectInContext!.scaleBy(x: 1, y: -1)
            effectInContext!.translateBy(x: 0, y: -size.height)
            effectInContext!.draw(cgImage!, in: imageRect)
            var effectInBuffer : vImage_Buffer = vImage_Buffer()
            effectInBuffer.data = effectInContext!.data
            effectInBuffer.width = UInt(effectInContext!.width)
            effectInBuffer.height = UInt(effectInContext!.height)
            effectInBuffer.rowBytes = effectInContext!.bytesPerRow
            UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
            let effectOutContext = UIGraphicsGetCurrentContext()
            var effectOutBuffer = vImage_Buffer()
            effectOutBuffer.data = effectOutContext!.data
            effectOutBuffer.width = UInt(effectOutContext!.width)
            effectOutBuffer.height = UInt(effectOutContext!.height)
            effectOutBuffer.rowBytes = effectOutContext!.bytesPerRow
            if hasBlur {
                let inputRadius = blurRadius * UIScreen.main.scale
                var radiusd = Double(inputRadius) * 3;
                radiusd = radiusd * 3 * sqrt(2 * Double.pi) / 4
                radiusd = radiusd + 0.5
                var radius = UInt32(floor(radiusd))
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
//                MemoryLayout.size(ofValue: floatingPointSaturationMatrix)/MemoryLayout.size(ofValue: floatingPointSaturationMatrix.first)
                let matrixSize = MemoryLayout.size(ofValue: floatingPointSaturationMatrix)/MemoryLayout.size(ofValue: floatingPointSaturationMatrix.first)
                var saturationMatrix : [__int16_t] = Array(repeating: 0, count: matrixSize)
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
                effectImage = UIGraphicsGetImageFromCurrentImageContext()!
                UIGraphicsEndImageContext()
            }
            if effectImageBuffersAreSwapped {
                effectImage = UIGraphicsGetImageFromCurrentImageContext()!
                UIGraphicsEndImageContext()
            }
        }
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        let outputContext = UIGraphicsGetCurrentContext()
        outputContext!.scaleBy(x: 1.0, y: -1.0)
        outputContext!.translateBy(x: 0, y: -size.height)
        // Draw base image.
        outputContext!.draw(cgImage!, in: imageRect)
//        CGContextDrawImage(outputContext, imageRect, cgImage)
        // Draw effect image.
        if (hasBlur) {
            outputContext!.saveGState()
            if ((maskImage) != nil) {
                outputContext!.clip(to: imageRect, mask: maskImage!.cgImage!)
            }
            outputContext!.draw(effectImage.cgImage!, in: imageRect)

            
            outputContext!.restoreGState()
        }
        // Add in color tint.
        if ((tintColor) != nil) {
            outputContext!.saveGState()
            outputContext!.setFillColor(tintColor!.cgColor)
            outputContext!.fill(imageRect)
            outputContext!.restoreGState()
        }
        // Output image is ready.
        let outputImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return outputImage
    }
    
}


