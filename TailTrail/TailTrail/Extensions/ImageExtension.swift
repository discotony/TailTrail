//
//  ImageExtension.swift
//  TailTrail
//
//  Created by Antony Bluemel on 3/26/24.
//

import SwiftUI

extension Image {
    func customResize(widthScale: Float) -> some View {
        let outputWidth = Float(UIScreen .main.bounds.size.width) * widthScale
        
        return self
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: CGFloat(outputWidth))
    }
    
    func customResize(width: CGFloat? = nil, height: CGFloat? = nil) -> some View {
        self
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: width, height: height)
    }
    
    func asUIImage() -> UIImage? {
        let controller = UIHostingController(rootView: self)
        
        let hostingView = controller.view
        
        guard let imageSize = hostingView?.systemLayoutSizeFitting(
            CGSize(width: CGFloat.infinity, height: CGFloat.infinity),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .required
        ) else {
            print("Bad Image Size: Saving Portion")
            return nil
        }
        
        controller.view.bounds = CGRect(origin: .zero, size: imageSize)
        controller.view.backgroundColor = .clear
        
        let renderer = UIGraphicsImageRenderer(size: imageSize)
        
        let image = renderer.image { context in
            controller.view.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
        return image
    }
    
    func applyIconStyle() -> some View {
        self
            .resizable()
            .frame(width: 20, height: 20)
    }
}

import UIKit

extension UIImage {
    func resize(to size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        self.draw(in: CGRect(origin: CGPoint.zero, size: size))
        guard let resizedImage = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return resizedImage
    }
    
    func convertToBuffer() -> CVPixelBuffer? {
        
        let attributes = [
            kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
            kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue
        ] as CFDictionary
        
        var pixelBuffer: CVPixelBuffer?
        
        let status = CVPixelBufferCreate(
            kCFAllocatorDefault, Int(self.size.width),
            Int(self.size.height),
            kCVPixelFormatType_32ARGB,
            attributes,
            &pixelBuffer)
        
        guard (status == kCVReturnSuccess) else {
            return nil
        }
        
        guard let pixelBuffer = pixelBuffer else { return nil }
        CVPixelBufferLockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
        
        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer)
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        
        guard let context = CGContext(
            data: pixelData,
            width: Int(self.size.width),
            height: Int(self.size.height),
            bitsPerComponent: 8,
            bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer),
            space: rgbColorSpace,
            bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
        else { return nil }
        
        context.translateBy(x: 0, y: self.size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        
        UIGraphicsPushContext(context)
        self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        UIGraphicsPopContext()
        
        CVPixelBufferUnlockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
        
        return pixelBuffer
    }
}
