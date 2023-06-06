//
//  QRCodeGenerator.swift
//  BusinessCardHolder
//

import SwiftUI

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

            return UIImage(cgImage: cgImage)
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
