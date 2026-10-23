//
//  Greek_BeersApp.swift
//  Greek Beers
//
//  Created by George Sidiropoulos on 11/7/23.
//

import SwiftUI

@main
struct Greek_BeersApp: App {

    @State private var vm = LocationsViewModel()

    var body: some Scene {
        WindowGroup {
            IntroView()
                .environment(vm)
        }
    }
}
