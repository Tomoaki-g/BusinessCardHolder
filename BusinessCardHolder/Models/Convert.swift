//
//  Convert.swift
//  BusinessCardHolder
//

import Foundation
import UIKit

func dateToString(date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.locale = Locale(identifier: "ja_JP")
    let strDate = formatter.string(from: date)
    return strDate
}

func stringToDate(string: String, format: String) -> Date {
    let formatter: DateFormatter = DateFormatter()
    formatter.calendar = Calendar(identifier: .gregorian)
    formatter.dateFormat = format
    return formatter.date(from: string)!
}

func imageToString(image: UIImage) -> String? {
    guard let imageData = image.jpegData(compressionQuality: 1.0) else { return nil }
    return imageData.base64EncodedString()
}

func stringToImage(imageString: String) -> UIImage? {
    let base64String = imageString.replacingOccurrences(of: " ", with: "+")
    guard let imageData = Data(base64Encoded: base64String) else { return nil }
    return UIImage(data: imageData)
}

extension String {
    func removingWhiteSpace() -> String {
        let whiteSpaces: CharacterSet = [" ", "　"]
        return self.trimmingCharacters(in: whiteSpaces)
    }
}
