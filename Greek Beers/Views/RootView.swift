//
//  RootView.swift
//  Zythos
//

import SwiftUI

struct RootView: View {

    var body: some View {
        TabView {
            DiscoverView()
                .tabItem { Label("Discover", systemImage: "map") }

            // Filled in by the Beers catalog
            ContentUnavailableView("Σύντομα", systemImage: "mug",
                                   description: Text("Ο κατάλογος με όλες τις ελληνικές μπύρες."))
                .tabItem { Label("Μπύρες", systemImage: "mug") }

            // Filled in by My Beer Journey
            ContentUnavailableView("Σύντομα", systemImage: "medal",
                                   description: Text("Οι μπύρες που δοκίμασες και το Beer Passport σου."))
                .tabItem { Label("Journey", systemImage: "medal") }
        }
    }
}

#Preview {
    RootView()
        .environment(BreweriesViewModel())
}
