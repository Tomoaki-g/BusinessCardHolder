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
    @State private var selectedOrder = "new"
    let order = ["new", "old"]
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
                                        .padding(EdgeInsets(top: 0, leading: 10, bottom: 15.0, trailing: 0))

                                    Text("Date: ")
                                        .font(.headline)
                                    Text(dateToString(date: data.date))
                                        .font(.title2)
                                        .padding(EdgeInsets(top: 0, leading: 10, bottom: 15.0, trailing: 0))

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
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing){
                    Menu {
                        Picker("", selection: $selectedOrder) {
                            ForEach(order, id: \.self) { value in
                                Text(value)
                            }
                        }
                        .pickerStyle(.inline)
                        .onChange(of: selectedOrder) { newValue in
                            if newValue == "new" {
                                dispCardData.sort(by: {$0.date > $1.date})
                            } else if newValue == "old" {
                                dispCardData.sort(by: {$0.date < $1.date})
                            }
                        }
                    } label: {
                        Label("", systemImage: "arrow.up.arrow.down")
                    }
                }
            }
            .onAppear {
                isFloatingButtonHidden = false
                let realm = try? Realm()
                if let data = realm?.objects(CardData.self) {
                    dispCardData = makeArrayData(data: data)
                    dispCardData.sort(by: {$0.date > $1.date})
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
