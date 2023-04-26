//
//  CardEditView.swift
//  BusinessCardHolder
//

import SwiftUI
import Combine

struct CardEditView: View {
    @Environment(\.presentationMode) var presentation
    @Environment(\.dismiss) var dismiss
    @State var dispCardData: CardData
    @State private var selectedDate = Date()
    @State private var source: UIImagePickerController.SourceType = .photoLibrary
    @State private var isActive: Bool = false
    @State private var showDialog: Bool = false
    @State var isFloatingButton: Bool
    @FocusState var focus: Bool
    let cardData: CardData

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
                    self.isActive = true
                }, label: {
                    Text("Upload")
                        .font(.title2)
                })
                .sheet(isPresented: $isActive, content: {
                    CameraView(image: $dispCardData.image, sourceType: $source, isActive: $isActive)
                })
                Spacer()
                
                Button(action: {
                    self.source = .camera
                    self.isActive = true
                }, label: {
                    Text("Take Photo")
                        .font(.title2)
                })
                .sheet(isPresented: $isActive, content: {
                    CameraView(image: $dispCardData.image, sourceType: $source, isActive: $isActive)
                })
                Spacer()
            }
            .padding(.bottom, 10)
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading) {
                    VStack(alignment: .leading) {
                        Text("Name: ")
                            .font(.title)
                            .padding(EdgeInsets(top: 10, leading: 0, bottom: -3, trailing: 0))
                        TextField("",text: $dispCardData.name)
                            .font(.system(size: 30))
                            .padding(.all, 5)
                            .border(Color.gray, width: 1)
                            .focused(self.$focus)
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
                            .padding(EdgeInsets(top: 10, leading: 0, bottom: -3, trailing: 0))
                        TextEditor(text: $dispCardData.note)
                            .font(.system(size: 30))
                            .padding(.all, 5)
                            .border(Color.gray, width: 1)
                            .frame(minHeight: 200)
                            .focused(self.$focus)
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .keyboard) {
                        Spacer()
                    }
                    ToolbarItem(placement: .keyboard) {
                        Button("Done") {
                            UIApplication.shared.endEditing()
                            dispCardData.name = dispCardData.name.removingWhiteSpace()
                            dispCardData.note = dispCardData.note.removingWhiteSpace()
                            self.focus = false
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
                    dispCardData.name = dispCardData.name.removingWhiteSpace()
                    dispCardData.note = dispCardData.note.removingWhiteSpace()
                    self.focus = false
                    
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
}

struct CardEditView_Previews: PreviewProvider {
    static var previews: some View {
        CardEditView(dispCardData: CardData.sampleData[0], isFloatingButton: false, cardData: CardData.sampleData[0])
    }
}
