//
//  ZythosApp.swift
//  Zythos
//
//  Created by George Sidiropoulos on 11/7/23.
//

import SwiftUI

@main
struct ZythosApp: App {

    @State private var vm = BreweriesViewModel()

    var body: some Scene {
        WindowGroup {
            IntroView()
                .environment(vm)
        }
    }
}
