//
//  TransactionCategory.swift
//  MyPersonalBudgetApp
//
//  Created by Абубакир on 29.11.2023.
//

import Foundation
import SwiftUI
import SwiftData

@Model
class TransactionCategory{
    var title: String
    var emoji: String
    var income: Bool
    var transactions: [Transaction]?
    
    @Relationship(deleteRule: .cascade, inverse: \Transaction.category)
    
    init(title: String, emoji: String, income: Bool) {
        self.title = title
        self.emoji = emoji
        self.income = income
    }
}

