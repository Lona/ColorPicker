//
//  NSImage+Blur.swift
//  ColorPicker
//
//  Created by Devin Abbott on 10/19/19.
//  Copyright © 2019 BitDisco, Inc. All rights reserved.
//

import AppKit

extension NSImage {

    public enum BlurType {
        case box
        case disc
        case gaussian

        fileprivate var ciFilterName: String {
            switch self {
            case .box: return "CIBoxBlur"
            case .disc: return "CIDiscBlur"
            case .gaussian: return "CIGaussianBlur"
            }
        }
    }

    public func blurred(type blurType: BlurType = .gaussian, radius: CGFloat) -> NSImage? {
        guard let tiffRepresentation = tiffRepresentation,
            let ciImage = CIImage(data: tiffRepresentation),
            let blur = CIFilter(name: blurType.ciFilterName) else { return nil }

        blur.setValue(ciImage, forKey: kCIInputImageKey)
        blur.setValue(radius, forKey: kCIInputRadiusKey)

        guard let outputImage = blur.outputImage else { return nil }

        let rep = NSCIImageRep(ciImage: outputImage)
        let nsImage: NSImage = NSImage(size: rep.size)
        nsImage.addRepresentation(rep)

        return nsImage
    }

//    public func blurred(radius: CGFloat) -> NSImage? {
//        guard let tiffRepresentation = tiffRepresentation,
//            let ciImage = CIImage(data: tiffRepresentation) else { return nil }
//
//        let blurredImage = ciImage.applyingGaussianBlur(sigma: Double(radius) / 2)
//
//        let rep = NSCIImageRep(ciImage: blurredImage)
//        let nsImage: NSImage = NSImage(size: rep.size)
//        nsImage.addRepresentation(rep)
//
//        return nsImage
//    }
}
