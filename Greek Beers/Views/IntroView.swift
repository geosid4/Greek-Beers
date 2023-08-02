//
//  IntroView.swift
//  Greek Beers
//
//  Created by George Sidiropoulos on 11/7/23.
//

import SwiftUI

struct IntroView: View {
    @State private var isActive = false
    @State private var size = 0.2
    @State private var opacity = 0.5
    
    var body: some View {
        if isActive {
            LocationsView()
        } else {
            VStack {
                VStack{
                    Image("beer")
                        .font(.system(size: 10))
                    Text("Beers in Greece")
                        .font(Font.custom("Baskerville-Bold", size: 40))
                        .foregroundColor(.black.opacity(0.80))
                }
                .scaleEffect(size)
                .opacity(opacity)
                .onAppear {
                    withAnimation(.easeIn(duration: 1.2)){
                        self.size = 0.5
                        self.opacity = 1.0
                    }
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    self.isActive = true
                }
            }
        }
    }
}

struct IntroView_Previews: PreviewProvider {
    static var previews: some View {
        IntroView()
    }
}
