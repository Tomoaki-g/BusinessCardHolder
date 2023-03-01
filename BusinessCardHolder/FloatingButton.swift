//
//  FloatingButton.swift
//  BusinessCardHolder
//

import SwiftUI

struct FloatingButton: View {
    @State var isActive = false
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                NavigationLink(
                    destination: CardEditView(dispCardData: CardData.init(), source: .photoLibrary, isActive: false, cardData: CardData.init()),
                    isActive: $isActive
                ) {
                        Button(
                            action: { isActive = true },
                            label: {
                                Image(systemName: "plus.circle.fill")
                                    .scaleEffect(x: 4, y: 4)
                                    .foregroundColor(.blue)
                        })
                        .frame(width: 60, height: 60)
                        .background(.white)
                        .cornerRadius(30.0)
                        .shadow(color: .gray, radius: 1.5, x: 0, y: 0)
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 22.0, trailing: 22.0))
                    }
            }
        }
    }
}

struct FloatingButton_Previews: PreviewProvider {
    static var previews: some View {
        FloatingButton()
    }
}
