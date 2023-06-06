//
//  CardListView.swift
//  BusinessCardHolder
//

import SwiftUI
import RealmSwift

struct CardListView: View {
    @State var isFloatingButtonHidden = false
    @State var dispCardData: [CardData]
    @State var searchText: String
    @State private var news: [Article] = []
    @State private var safariURL: URL? = nil
    @State private var currentNewsIndex = 0
    @State private var isNewsTimerRunning = false
    @State private var selectedOrder = "new"
    private let newsTimerInterval: TimeInterval = 5
    let cardData: CardData
    let article: Article
    
    var newsView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(news.indices, id: \.self) { index in
                    if index >= currentNewsIndex && index < currentNewsIndex + 3 {
                        Button(action: {
                            if news[index].url != "" {
                                UIApplication.shared.open(URL(string: news[index].url)!)
                            }
                        }) {
                            Text(news[index].title)
                                .font(.subheadline)
                                .foregroundColor(.black)
                                .lineLimit(1)
                                .padding(.vertical, 5)
                                .padding(.horizontal, 10)
                                .cornerRadius(10)
                        }
                        .transition(.opacity)
                        .id(index)
                    }
                }
            }
            .padding(.horizontal)
            .frame(height: 40)
            .background(Color.gray.opacity(0.1))
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    newsView
                        .id(currentNewsIndex)
                        .onAppear {
                            isNewsTimerRunning = true
                            startNewsTimer()
                        }
                        .onDisappear {
                            stopNewsTimer()
                        }
                    
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
                fetchNews()
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
        .listStyle(.plain)
    }
    
    private func startNewsTimer() {
        DispatchQueue.main.asyncAfter(deadline: .now() + newsTimerInterval) {
            if isNewsTimerRunning && news.count != 0 {
                currentNewsIndex = (currentNewsIndex + 1) % news.count
                startNewsTimer()
            }
        }
    }

    private func stopNewsTimer() {
        isNewsTimerRunning = false
    }
    
    private func fetchNews() {
        article.getArticles { news in
            DispatchQueue.main.async {
                self.news = news
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
        CardListView(dispCardData: CardData.sampleData, searchText: "", cardData: CardData.sampleData[0], article: Article.init(title: "", url: ""))
    }
}
