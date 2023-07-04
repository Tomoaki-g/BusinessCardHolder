//
//  FirebaseStorage.swift
//  BusinessCardHolder
//

import Firebase
import FirebaseStorage

final public class FirebaseStorage {
    public static let shared = FirebaseStorage()
    let fileName = "cardData"

    private init() {}
        
    func uploadData(data: CardData) {
        let storageRef = Storage.storage().reference()
        let txtRef = storageRef.child("\(fileName)_\(data.id).txt")
        if let inputData = convertToString(data: data).data(using: .utf8) {
            txtRef.putData(inputData, metadata: nil, completion: { (metadata, error) in
                if error != nil {
                    print(error as Any)
                } else {
                    print(metadata!.path!)
                }
            })
        }
    }
    
    func downloadData(qrCodeData:String, completion: @escaping (String) -> Void) {
        let storageRef = Storage.storage().reference()
        let imageRef = storageRef.child("\(qrCodeData).txt")
        imageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                print(error)
                completion("")
            } else {
                print(data as Any)
                if let data = data {
                    completion(String(data: data, encoding: .utf8)!)
                }
            }
        }
    }
    
    func deleteData(data: CardData) {
        let storageRef = Storage.storage().reference()
        let imageRef = storageRef.child("\(fileName)_\(data.id).txt")
        imageRef.delete { error in
            if let error = error {
                print(error)
            }
        }
    }
}
