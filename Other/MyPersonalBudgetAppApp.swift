//
//  MyPersonalBudgetAppApp.swift
//  MyPersonalBudgetApp
//
//  Created by Абубакир on 29.11.2023.
//

import SwiftUI
import SwiftData

@main
struct MyPersonalBudgetAppApp: App {
    var body: some Scene {
        WindowGroup {
            MainView()
        }
        .modelContainer(for: [Transaction.self, TransactionCategory.self])
    }
}
