//
//  CardEditView.swift
//  BusinessCardHolder
//

import SwiftUI
import Combine
import Foundation
import FirebaseStorage

struct CardEditView: View {
    @Environment(\.presentationMode) var presentation
    @Environment(\.dismiss) var dismiss
    @Binding var dispCardData: CardData
    @State private var qrCodeData: String = ""
    @State private var source: UIImagePickerController.SourceType = .photoLibrary
    @State private var isCameraActive: Bool = false
    @State private var isScanActive: Bool = false
    @State private var showDialog: Bool = false
    @State var isFloatingButton: Bool
    @FocusState var nameFocus: Bool
    @FocusState var noteFocus: Bool
    let cardData: CardData
    private let qrCodeGenerator = QRCodeGenerator()

    var body: some View {
        VStack {
            VStack(alignment: .center) {
                if let imageData = $dispCardData.image.wrappedValue {
                    Image(uiImage: UIImage(data: imageData) ?? UIImage(named: "noimage")!)
                        .resizable()
                        .scaledToFit()
                } else {
                    Image("noimage")
                        .resizable()
                        .scaledToFit()
                }
            }

            Divider()
            
            HStack {
                Spacer()
                Button(action: {
                    self.source = .photoLibrary
                    self.isCameraActive = true
                }, label: {
                    Text("Upload")
                        .font(.title3)
                })
                .sheet(isPresented: $isCameraActive, content: {
                    CameraView(image: $dispCardData.image, sourceType: $source, isCameraActive: $isCameraActive)
                        .edgesIgnoringSafeArea(.all)
                })

                Spacer()
                
                Button(action: {
                    self.source = .camera
                    self.isCameraActive = true
                }, label: {
                    Text("Take Photo")
                        .font(.title3)
                })
                .sheet(isPresented: $isCameraActive, content: {
                    CameraView(image: $dispCardData.image, sourceType: $source, isCameraActive: $isCameraActive)
                        .edgesIgnoringSafeArea(.all)
                })

                Spacer()

                Button(action: {
                    self.source = .camera
                    self.isScanActive = true
                }, label: {
                    Text("Read QR code")
                        .font(.title3)
                })
                .sheet(isPresented: $isScanActive, content: {
                    ScannerView(isScanActive: $isScanActive, qrCodeData: $qrCodeData)
                        .onDisappear {
                            if qrCodeData != "" {
                                parseData(qrCodeData: qrCodeData)
                            }
                        }
                })
                
                Spacer()
            }
            .padding(.bottom, 10)
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading) {
                    VStack(alignment: .leading) {
                        Text("Name: ")
                            .font(.title)
                            .padding(EdgeInsets(top: 10, leading: 0, bottom: -5, trailing: 0))
                        TextEditor(text: $dispCardData.name)
                            .font(.system(size: 30))
                            .padding(.all, 5)
                            .border(Color.gray, width: 1)
                            .frame(height: 50)
                            .focused(self.$nameFocus)
                    }

                    VStack(alignment: .leading) {
                        Text("Date: ")
                            .font(.title)
                            .padding(.top, 10)
                        DatePicker("", selection: $dispCardData.date, displayedComponents: .date)
                            .environment(\.locale, Locale(identifier: "ja_JP"))
                            .labelsHidden()
                            .scaleEffect(x: 1.5, y: 1.5)
                            .padding(.leading, 30)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Note: ")
                            .font(.title)
                            .padding(EdgeInsets(top: 10, leading: 0, bottom: -5, trailing: 0))
                        TextEditor(text: $dispCardData.note)
                            .font(.system(size: 30))
                            .padding(.all, 5)
                            .border(Color.gray, width: 1)
                            .frame(minHeight: 200)
                            .focused(self.$noteFocus)
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .keyboard) {
                        Spacer()
                    }
                    ToolbarItem(placement: .keyboard) {
                        Button("Done") {
                            UIApplication.shared.endEditing()
                            self.nameFocus = false
                            self.noteFocus = false
                        }
                    }
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    UIApplication.shared.endEditing()
                    self.nameFocus = false
                    self.noteFocus = false

                    if dispCardData.name != "" {
                        let result = cardData.saveData(id: dispCardData.id, name: dispCardData.name, image: UIImage(data: dispCardData.image), date: dispCardData.date, note: dispCardData.note)
                        if result {
                            self.presentation.wrappedValue.dismiss()
                        }
                    } else {
                        showDialog = true
                    }
                }, label: {
                    Text("Save")
                })
                .font(.title2)
                .alert("", isPresented: $showDialog) {
                    Button("OK", role: .cancel) {
                        showDialog = false
                    }
                } message: {
                    Text("Enter name.")
                }
            }
        }
        .onAppear {
            NotificationCenter.default.addObserver(self, selector: #selector(KeyboardResponder.keyboardWillShow), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(KeyboardResponder.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        }
        .onDisappear {
            if isFloatingButton {
                dispCardData.id = ""
                dispCardData.name = ""
                dispCardData.image = UIImage(named: "noimage")!.jpegData(compressionQuality: 1.0)!
                dispCardData.date = Date()
                dispCardData.note = ""
            }
        }
    }
    
    private func parseData(qrCodeData: String) {
        let storageRef = Storage.storage().reference()
        let imageRef = storageRef.child("cardData.txt")
        imageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                print(error)
            } else {
                print(data as Any)
                if let data = data {
                    let dataValue = String(data: data, encoding: .utf8)!
                    let components = dataValue.components(separatedBy: ",")
                    if components.count == 5 {
                        let id = components[0]
                        let name = components[1]
                        let imageString = components[2]
                        let image = Data(base64Encoded: imageString)
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
                        let date = dateFormatter.date(from: components[3])
                        let note = components[4]
                        
                        if let image = image, let date = date {
                            dispCardData.id = id
                            dispCardData.name = name
                            dispCardData.image = image
                            dispCardData.date = date
                            dispCardData.note = note

                            self.nameFocus = true
                        }
                    }
                }
            }
        }
    }
}

struct CardEditView_Previews: PreviewProvider {
    static var previews: some View {
        CardEditView(dispCardData: .constant(CardData.sampleData[0]), isFloatingButton: false, cardData: CardData.sampleData[0])
    }
}
