//
//  LaunchView.swift
//  BusinessCardHolder
//

import UIKit
import SwiftUI

struct LaunchView: View {
    @State private var isAnimating = false
    @State private var isShowingCameraRoll = false
    @State private var image: UIImage?
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.startColor, Color.endColor]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            Image("LaunchScreenImage")
                .resizable()
                .scaledToFit()
                .frame(width: 250, height: 250)
                .padding(.bottom, 50)
        }
        .background(.white)
    }
}

extension Color {
    static let startColor = Color("LaunchBackgroundStartColor")
    static let endColor = Color("LaunchBackgroundEndColor")
}

struct LaunchView_Previews: PreviewProvider {
    static var previews: some View {
        LaunchView()
    }
}
