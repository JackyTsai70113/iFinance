//
//  iFinanceApp.swift
//  iFinance
//
//  Created by 蔡孟哲 on 2026/3/19.
//

import SwiftUI

@main
struct iFinanceApp: App {
    @State private var store = AppStore()

    var body: some Scene {
        WindowGroup {
            ContentView(store: store)
        }
    }
}
