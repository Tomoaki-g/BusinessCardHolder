//
//  CardEditData.swift
//  BusinessCardHolder
//

import Foundation
import SwiftUI

struct CardEditData: Equatable {
    var id: String = UUID().uuidString
    var name: String
    var image: UIImage?
    var date: Date
    var note: String
    
    init(name: String, image: UIImage?, date: Date, note: String) {
        self.name = name
        self.image = image
        self.date = date
        self.note = note
    }
}

extension CardEditData {
    static let cardEditData = CardEditData.self
    
    func setEditingData(image: UIImage?, name: String, date: Date, note: String) -> CardEditData {
        var tempEditData: CardEditData
        
        tempEditData = .init(name: "", image: UIImage(named: "noimage")!, date: Date(), note: "")
        
        tempEditData.image = image
        tempEditData.name = name
        tempEditData.date = date
        tempEditData.note = note
        
        return tempEditData
    }
}
