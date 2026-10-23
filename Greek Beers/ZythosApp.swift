//
//  ZythosApp.swift
//  Zythos
//
//  Created by George Sidiropoulos on 11/7/23.
//

import SwiftUI

@main
struct ZythosApp: App {

    @State private var breweries = BreweriesViewModel()
    @State private var beers = BeersViewModel()
    @State private var router = AppRouter()

    var body: some Scene {
        WindowGroup {
            IntroView()
                .environment(breweries)
                .environment(beers)
                .environment(router)
        }
    }
}
