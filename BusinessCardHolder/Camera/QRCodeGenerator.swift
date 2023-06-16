//
//  QRCodeGenerator.swift
//  BusinessCardHolder
//

import SwiftUI
import UIKit

struct QRCodeGenerator {
    let dataUrl: URL = {
        let url = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask).first!
        let dataUrl = url.appendingPathComponent("cardData.json")
        return dataUrl
    }()
    
    func generate(with inputCardData: CardData) -> UIImage? {
        guard let qrFilter = CIFilter(name: "CIQRCodeGenerator")
        else { return nil }

        if saveTempData(data: inputCardData) {
            let inputData = dataUrl.absoluteString.data(using: .utf8)
            qrFilter.setValue(inputData, forKey: "inputMessage")
            qrFilter.setValue("H", forKey: "inputCorrectionLevel")

            guard let ciImage = qrFilter.outputImage
            else { return nil }

            let sizeTransform = CGAffineTransform(scaleX: 10, y: 10)
            let scaledCiImage = ciImage.transformed(by: sizeTransform)

            let context = CIContext()
            guard let cgImage = context.createCGImage(scaledCiImage, from: scaledCiImage.extent)
            else { return nil }

            return UIImage(cgImage: cgImage).composited(withSmallCenterImage: UIImage(named: "AppIcon")!)
        } else {
            return nil
        }
    }
}

extension QRCodeGenerator {
    func saveTempData(data: CardData) -> Bool {
        let inputData = try? JSONEncoder().encode(data)
        do {
            try inputData?.write(to: dataUrl)
            return true
        } catch {
            return false
        }
    }
}

extension UIImage {
    func composited(withSmallCenterImage centerImage: UIImage) -> UIImage {
        return UIGraphicsImageRenderer(size: self.size).image { context in
            let imageWidth = context.format.bounds.width
            let imageHeight = context.format.bounds.height
            let centerImageLength = imageWidth < imageHeight ? imageWidth / 5 : imageHeight / 5
            let centerImageRadius = centerImageLength * 0.2
            draw(in: CGRect(origin: CGPoint(x: 0, y: 0),
                            size: context.format.bounds.size))
            let centerImageRect = CGRect(x: (imageWidth - centerImageLength) / 2,
                                         y: (imageHeight - centerImageLength) / 2,
                                         width: centerImageLength,
                                         height: centerImageLength)
            let roundedRectPath = UIBezierPath(roundedRect: centerImageRect,
                                               cornerRadius: centerImageRadius)
            roundedRectPath.addClip()
            centerImage.draw(in: centerImageRect)
        }
    }
}
