//
//  CardDetailView.swift
//  BusinessCardHolder
//

import SwiftUI
import RealmSwift

struct CardDetailView: View {
    @Environment(\.presentationMode) var presentation
    @State var dispCardData: CardData
    @State private var showAlert = false
    @State private var showActivityView = false
    @State private var qrCodeImage: UIImage?
    private let qrCodeGenerator = QRCodeGenerator()

    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .center) {
                if let image = dispCardData.image {
                    Image(uiImage: UIImage(data: image) ?? UIImage(named: "noimage")!)
                        .resizable()
                        .scaledToFit()
                } else {
                    Image("noimage")
                        .resizable()
                        .scaledToFit()
                }
            }
            .frame(maxWidth: .infinity)
            
            Divider()
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading) {
                    Text("Name: ")
                        .font(.title)
                    Text(dispCardData.name)
                        .font(.largeTitle)
                        .padding(EdgeInsets(top: 0, leading: 15, bottom: 10, trailing: 0))
                    
                    Text("Date: ")
                        .font(.title)
                    Text(dateToString(date: dispCardData.date))
                        .font(.largeTitle)
                        .padding(EdgeInsets(top: 0, leading: 15, bottom: 10, trailing: 0))
                    
                    Text("Note: ")
                        .font(.title)
                    Text(dispCardData.note)
                        .font(.largeTitle)
                        .padding(.leading, 15)
                }
                .padding(.vertical, 10)
            }
        }
        .padding()
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: CardEditView(dispCardData: $dispCardData, isFloatingButton: false, cardData: dispCardData)
                    .onDisappear {
                        let realm = try? Realm()
                        if let data = realm?.objects(CardData.self).where({ $0.id == dispCardData.id }).first {
                            dispCardData = makeData(data: data)
                        }
                    }) {
                        Text("Edit")
                            .font(.title2)
                    }
            }
        }
        .safeAreaInset(edge: .bottom) {
            HStack {
                Button(action: {
                    self.showActivityView = true
                }) {
                    Image(systemName: "qrcode")
                        .font(.title2)
                        .foregroundColor(.blue)
                        .scaleEffect(x: 1.4, y: 1.4)
                }
                .fullScreenCover(isPresented: $showActivityView) {
                    if let qrCodeImage {
                        ZStack {
                            Color.black.opacity(0.4)
                                .backgroundClearSheet()
                                .edgesIgnoringSafeArea(.all)
                            
                            VStack(alignment: .center) {
                                Text("共有用QRコード")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .shadow(color: .black, radius: 3, x: 2, y: 2)
                                
                                Image(uiImage: qrCodeImage)
                                    .resizable()
                                    .frame(width: 200, height: 200)
                            }
                        }
                        .onTapGesture {
                            showActivityView = false
                        }
                        .onAppear {
                            FirebaseStorage.shared.uploadData(data: dispCardData)
                        }
                        .onDisappear {
                            FirebaseStorage.shared.deleteData(data: dispCardData)
                        }
                    }
                }
                .padding(EdgeInsets(top: 0, leading: 30, bottom: 15, trailing: 0))

                
                Spacer()
                
                Button(action: {
                    self.showAlert = true
                }) {
                    Image(systemName: "trash")
                        .font(.title2)
                        .foregroundColor(.blue)
                        .scaleEffect(x: 1.4, y: 1.4)
                }
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 15, trailing: 30))
                .alert("", isPresented: $showAlert) {
                    Button("Delete", role: .destructive) {
                        dispCardData.deleteData(cardData: dispCardData)
                        self.presentation.wrappedValue.dismiss()
                    }
                } message: {
                    Text("Are you sure you want to delete this card?")
                }
                
            }
        }
        .onAppear {
            UIApplication.shared.endEditing()
            qrCodeImage = qrCodeGenerator.generate(with: dispCardData)
        }
    }
}

struct BackgroundClearView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        Task {
            view.superview?.superview?.backgroundColor = .clear
        }
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}

extension View {
    func backgroundClearSheet() -> some View {
        background(BackgroundClearView())
    }
}

struct CardDetailView_Previews: PreviewProvider {
    static var previews: some View {
        CardDetailView(dispCardData: CardData.sampleData[0])
    }
}
