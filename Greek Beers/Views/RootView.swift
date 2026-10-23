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

    // Opens on the beers: most visits start from a beer in hand, not a place
    var tab: AppTab = .beers

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
            BeersView()
                .tabItem { Label("Μπύρες", systemImage: "mug") }
                .tag(AppTab.beers)

            DiscoverView()
                .tabItem { Label("Χάρτης", systemImage: "map") }
                .tag(AppTab.discover)

            JourneyView()
                .tabItem { Label("Διαβατήριο", systemImage: "book.closed") }
                .tag(AppTab.journey)
        }
        .onAppear(perform: styleLargeTitles)
    }

    // Large navigation titles in the same heavy condensed face as Font.display. Set here rather
    // than in the App's init: touching UIKit appearance that early loses the amber accent colour
    private func styleLargeTitles() {
        let largeTitle = UIFont.systemFont(ofSize: 34, weight: .heavy, width: .condensed)
        UINavigationBar.appearance().largeTitleTextAttributes = [
            .font: UIFontMetrics(forTextStyle: .largeTitle).scaledFont(for: largeTitle)
        ]
    }
}

#Preview {
    RootView()
        .environment(BreweriesViewModel())
        .environment(BeersViewModel())
        .environment(AppRouter())
        .modelContainer(for: [BeerLog.self, BreweryLog.self], inMemory: true)
}
