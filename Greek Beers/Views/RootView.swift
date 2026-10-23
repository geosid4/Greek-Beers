//
//  RootView.swift
//  Zythos
//

import SwiftUI

enum AppTab: Hashable {
    case discover
    case beers
    case journey
}

// Owns the selected tab, so one tab can send the user to another
@Observable
final class AppRouter {

    var tab: AppTab = .discover

    func showOnMap(_ brewery: Brewery, using breweries: BreweriesViewModel) {
        tab = .discover
        breweries.select(brewery)
    }
}

struct RootView: View {

    @Environment(AppRouter.self) private var router

    var body: some View {
        @Bindable var router = router

        TabView(selection: $router.tab) {
            DiscoverView()
                .tabItem { Label("Discover", systemImage: "map") }
                .tag(AppTab.discover)

            BeersView()
                .tabItem { Label("Μπύρες", systemImage: "mug") }
                .tag(AppTab.beers)

            // Filled in by My Beer Journey
            ContentUnavailableView("Σύντομα", systemImage: "medal",
                                   description: Text("Οι μπύρες που δοκίμασες και το Beer Passport σου."))
                .tabItem { Label("Journey", systemImage: "medal") }
                .tag(AppTab.journey)
        }
    }
}

#Preview {
    RootView()
        .environment(BreweriesViewModel())
        .environment(BeersViewModel())
        .environment(AppRouter())
}
