//
//  SearchView.swift
//  BusinessCardHolder
//

import SwiftUI
import RealmSwift

struct SearchView: View {
    @State var searchText: String
    @State var dispCardData: [CardData]
    
    var filteredDispCardData: [CardData] {
        dispCardData.filter { cardData in
            (cardData.name.contains(searchText))
        }
    }

    var body: some View {
        VStack {
            HStack {
                Text("\(filteredDispCardData.count)")
                    .font(.title2)
                    .fontWeight(.semibold)
                Text("results")
                    .baselineOffset(-5)

                Spacer()
            }
            .padding(EdgeInsets(top: 10, leading: 25, bottom: 0, trailing: 0))

            List {
                ForEach(filteredDispCardData) { data in
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
                        
                        NavigationLink(destination: CardDetailView(dispCardData: data)) {
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
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal){
                TextField("Search", text: $searchText)
                    .frame(maxWidth: 250)
                    .padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
                    .overlay(
                        RoundedRectangle(cornerRadius: 50)
                            .stroke(.black, lineWidth: 0.5)
                    )
            }
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("done") {
                    UIApplication.shared.endEditing()
                }
            }
        }
        .onAppear {
            let realm = try? Realm()
            if let data = realm?.objects(CardData.self) {
                dispCardData = makeArrayData(data: data)
            } else {
                dispCardData = []
            }
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView(searchText: "", dispCardData: CardData.sampleData)
    }
}
