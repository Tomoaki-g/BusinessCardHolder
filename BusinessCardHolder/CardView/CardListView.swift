//
//  CardListView.swift
//  BusinessCardHolder
//

import SwiftUI
import RealmSwift

struct CardListView: View {
    @State var isFloatingButtonHidden = false
    @State var newImage = UIImage()
    @State var dispCardData: [CardData]
    let cardData: CardData
    
    var body: some View {
        NavigationView {
            ZStack {
                List {
                    ForEach(dispCardData) { data in
                        HStack {
                            if let image = data.image {
                                Image(uiImage: UIImage(data: image) ?? UIImage(named: "noimage")!)
                                    .resizable()
                                    .scaledToFit()
                            } else {
                                Image("noimage")
                                    .resizable()
                                    .scaledToFit()
                            }
                            
                            NavigationLink(destination: CardDetailView(dispCardData: data)
                                .onAppear { isFloatingButtonHidden = true }) {
                                VStack(alignment: .leading) {
                                    Text("Name: ")
                                        .font(.headline)
                                    Text(data.name)
                                        .font(.title2)
                                        .padding(.leading, 10)

                                    Spacer()

                                    Text("Date: ")
                                        .font(.headline)
                                    Text(dateToString(date: data.date))
                                        .font(.title2)
                                        .padding(.leading, 10)

                                    Spacer()

                                    Text("Note: ")
                                        .font(.headline)
                                    Text(data.note)
                                        .font(.title2)
                                        .padding(.leading, 10)

                                    Spacer()
                                }
                                .padding(.vertical, 10)
                            }
                        }
                        .contentShape(Rectangle())
                    }
                }
                .navigationTitle("")
                
                if isFloatingButtonHidden {
                    FloatingButton().hidden()
                } else {
                    FloatingButton()
                }
            }
            .onAppear {
                isFloatingButtonHidden = false
                let realm = try? Realm()
                if let data = realm?.objects(CardData.self) {
                    dispCardData = makeArrayData(data: data)
                } else {
                    dispCardData = []
                }
            }
        }
    }
}

struct CardListView_Previews: PreviewProvider {
    static var previews: some View {
        CardListView(dispCardData: CardData.sampleData, cardData: CardData.sampleData[0])
    }
}
