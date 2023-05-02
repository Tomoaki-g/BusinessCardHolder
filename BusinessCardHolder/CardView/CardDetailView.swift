//
//  CardDetailView.swift
//  BusinessCardHolder
//

import SwiftUI
import RealmSwift

struct CardDetailView: View {
    @State var dispCardData: CardData
    @Environment(\.presentationMode) var presentation
    @State private var showAlert = false
    @State private var didTapBackButton = true
    @State private var image = UIImage()

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
                    .onAppear {
                        didTapBackButton = false
                    }
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
        }
    }
}

struct CardDetailView_Previews: PreviewProvider {
    static var previews: some View {
        CardDetailView(dispCardData: CardData.sampleData[0])
    }
}
