//
//  CardListView.swift
//  BusinessCardHolder
//

import SwiftUI
import RealmSwift

struct CardListView: View {
    @State var isFloatingButtonHidden = false
    @State private var newImage = UIImage()
    @State var dispCardData: [CardData]
    @State var searchText: String
    @State private var selectedOrder = "new"
    private let order = ["new", "old"]
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
                                        .padding(EdgeInsets(top: 0, leading: 10, bottom: 15, trailing: 0))

                                    Text("Date: ")
                                        .font(.headline)
                                    Text(dateToString(date: data.date))
                                        .font(.title2)
                                        .padding(EdgeInsets(top: 0, leading: 10, bottom: 15, trailing: 0))

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
                    .onDelete { (offsets) in
                        offsets.forEach { offset in
                            dispCardData[offset].deleteData(cardData: dispCardData[offset])
                        }
                        dispCardData.remove(atOffsets: offsets)
                        let realm = try? Realm()
                        if let data = realm?.objects(CardData.self) {
                            dispCardData = makeArrayData(data: data)
                        }
                    }
                }
                
                if isFloatingButtonHidden {
                    FloatingButton().hidden()
                } else {
                    FloatingButton()
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        PickOrder(selectedOrder: $selectedOrder)
                    } label: {
                        Label("", systemImage: "arrow.up.arrow.down")
                    }
                    .onChange(of: selectedOrder) { newValue in
                        if newValue == "new" {
                            dispCardData.sort(by: {$0.date > $1.date})
                        } else if newValue == "old" {
                            dispCardData.sort(by: {$0.date < $1.date})
                        }
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink {
                        SearchView(searchText: searchText, dispCardData: dispCardData)
                    } label: {
                        Label("", systemImage: "magnifyingglass")
                    }
                }
            }
            .onAppear {
                UIApplication.shared.endEditing()
                isFloatingButtonHidden = false
                let realm = try? Realm()
                if let data = realm?.objects(CardData.self) {
                    dispCardData = makeArrayData(data: data)
                    if selectedOrder == "new" {
                        dispCardData.sort(by: {$0.date > $1.date})
                    } else if selectedOrder == "old" {
                        dispCardData.sort(by: {$0.date < $1.date})
                    }
                } else {
                    dispCardData = []
                }
            }
            .onDisappear {
                searchText = ""
            }
        }
    }
}

struct PickOrder: View {
    let order = ["new", "old"]
    @Binding var selectedOrder: String
    var body: some View {
        VStack {
            Picker("", selection: $selectedOrder) {
                ForEach(order, id: \.self) { newValue in
                    Text(newValue)
                }
            }
            .pickerStyle(.inline)
        }
    }
}

struct CardListView_Previews: PreviewProvider {
    static var previews: some View {
        CardListView(dispCardData: CardData.sampleData, searchText: "", cardData: CardData.sampleData[0])
    }
}
