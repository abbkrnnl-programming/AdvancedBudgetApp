//
//  Transaction.swift
//  MyPersonalBudgetApp
//
//  Created by Абубакир on 29.11.2023.
//

import Foundation
import SwiftUI
import SwiftData

@Model
class Transaction {
    var title: String
    var amount: Double
    var date: Date
    var income: Bool
    var category: TransactionCategory?
    
    init(title: String, amount: Double, date: Date, income: Bool, category: TransactionCategory? = nil) {
        self.title = title
        self.amount = amount
        self.date = date
        self.income = income
        self.category = category
    }
}
