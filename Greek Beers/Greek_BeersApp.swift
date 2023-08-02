//
//  Greek_BeersApp.swift
//  Greek Beers
//
//  Created by George Sidiropoulos on 11/7/23.
//

import SwiftUI

@main
struct Greek_BeersApp: App {
    
    @StateObject private var vm = LocationsViewModel()
    
    var body: some Scene {
        WindowGroup {
            IntroView()
                .environmentObject(vm)
        }
    }
}
