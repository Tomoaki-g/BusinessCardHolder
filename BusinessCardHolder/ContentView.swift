//
//  ContentView.swift
//  BusinessCardHolder
//

import UIKit
import SwiftUI

struct ContentView: View {
    @State private var count = 1
    @State private var isHidden = false
    
    var body: some View {
        ZStack {
            CardListView(dispCardData: [], searchText: "", cardData: CardData(id: UUID().uuidString, name: "", image: UIImage(named: "noimage")!.jpegData(compressionQuality: 1.0)!, date: Date(), note: ""))
            LaunchView()
                .opacity(isHidden ? 0 : 1)
                .onAppear() {
                    Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
                        self.count -= 1
                        if self.count == 0 {
                            timer.invalidate()
                            withAnimation(.linear(duration: 0.3)) {
                                self.isHidden = true
                            }
                        }
                    }
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
