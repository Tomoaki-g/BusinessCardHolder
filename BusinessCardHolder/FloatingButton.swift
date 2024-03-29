//
//  FloatingButton.swift
//  BusinessCardHolder
//

import SwiftUI

struct FloatingButton: View {
    @State private var isActive = false
    @State private var isFloatingButton = false

    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                NavigationLink(
                    destination: CardEditView(dispCardData: .constant(CardData(id: UUID().uuidString, name: "", image: UIImage(named: "noimage")!.jpegData(compressionQuality: 1.0)!, date: Date(), note: "")), isFloatingButton: true, cardData: CardData.init()),
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
