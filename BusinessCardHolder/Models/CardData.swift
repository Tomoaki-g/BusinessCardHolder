//
//  CardData.swift
//  BusinessCardHolder
//

import RealmSwift

class CardData: Object, Identifiable, Codable {
    @Persisted(primaryKey: true) var id: String = UUID().uuidString
    @Persisted var name: String
    @Persisted var image: Data
    @Persisted var date: Date
    @Persisted var note: String

    override static func primaryKey() -> String? {
        return "id"
    }
    
    override init() {
        super.init()
    }
    
    init(id: String, name: String, image: Data, date: Date, note: String) {
        super.init()
        self.id = id
        self.name = name
        self.image = image
        self.date = date
        self.note = note
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name, image, date, note
    }
}

extension CardData {
    func saveData(id: String, name: String, image: UIImage?, date: Date, note: String) -> Bool {
        let cardData = CardData()
        var newImage: Data
        
        if let image = image {
            newImage = image.jpegData(compressionQuality: 1.0)!
        } else {
            newImage = UIImage(named: "noimage")!.jpegData(compressionQuality: 1.0)!
        }
        
        if let data = realm?.objects(CardData.self).where({ $0.id == id }).first {
            cardData.id = data.id
        } else {
            cardData.id = id
        }
        cardData.name = name.removingWhiteSpace()
        cardData.image = newImage
        cardData.date = date
        cardData.note = note.removingWhiteSpace()
        
        let realm = try? Realm()
        try? realm?.write {
            if let data = realm?.objects(CardData.self).where({ $0.id == id }).first {
                realm?.delete((realm?.objects(CardData.self).filter("id=%@", data.id))!)
            }
            realm?.add(cardData)
        }

        return true
    }
    
    func getData() -> Any {
        let realm = try? Realm()
        let cardData = realm?.objects(CardData.self)
        return cardData as Any
    }

    func deleteData(cardData: CardData) {
        let realm = try? Realm()
        try? realm?.write{
            realm?.delete((realm?.objects(CardData.self).filter("id=%@", cardData.id))!)
        }
    }
}

#if DEBUG
extension CardData {
    static var sampleData = [
        CardData(id: UUID().uuidString, name: "John Doe", image: UIImage(named: "noimage")!.jpegData(compressionQuality: 1.0)!, date: Date(), note: "Don't forget about taxi receipts"),
        CardData(id: UUID().uuidString, name: "Michael Stanford", image: UIImage(named: "noimage")!.jpegData(compressionQuality: 1.0)!, date: Date().addingTimeInterval(86400), note: "Check tech specs in shared folder"),
        CardData(id: UUID().uuidString, name: "Kylie Sinclair", image: UIImage(named: "noimage")!.jpegData(compressionQuality: 1.0)!, date: Date().addingTimeInterval(172800), note: "Optometrist closes at 6:00PM"),
        CardData(id: UUID().uuidString, name: "Michael Cavill", image: UIImage(named: "noimage")!.jpegData(compressionQuality: 1.0)!, date: Date().addingTimeInterval(345600), note: "Collaborate with project manager"),
        CardData(id: UUID().uuidString, name: "Georgia Smith", image: UIImage(named: "noimage")!.jpegData(compressionQuality: 1.0)!, date: Date().addingTimeInterval(691200), note: "Review portfolio"),
        CardData(id: UUID().uuidString, name: "James Connor", image: UIImage(named: "noimage")!.jpegData(compressionQuality: 1.0)!, date: Date().addingTimeInterval(13182400),  note: "v0.9 out on Friday")
    ]
}
#endif

func makeArrayData(data: Results<CardData>) -> [CardData] {
    var cardData = [CardData]()
    for _ in (0 ..< data.count) {
        cardData.append(contentsOf: [CardData(id: UUID().uuidString, name: "", image: UIImage(named: "noimage")!.jpegData(compressionQuality: 1.0)!, date: Date(), note: "")])
    }
    
    for i in 0..<data.count {
        cardData[i].id = data[i].id
        cardData[i].name = data[i].name
        cardData[i].image = data[i].image
        cardData[i].date = data[i].date
        cardData[i].note = data[i].note
    }
    
    return cardData
}

func makeData(data: CardData) -> CardData {
    let cardData = CardData()
    
    cardData.id = data.id
    cardData.name = data.name
    cardData.image = data.image
    cardData.date = data.date
    cardData.note = data.note
    
    return cardData
}
