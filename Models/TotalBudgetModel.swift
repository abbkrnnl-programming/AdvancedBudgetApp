//
//  TotalBudgetModel.swift
//  MyPersonalBudgetApp
//
//  Created by Абубакир on 29.11.2023.
//

import Foundation

class BudgetModel: ObservableObject {
    @Published var expenseTotalWeek: Double = 0
    @Published var incomeTotalWeek: Double = 0
    @Published var expenseTotalMonth: Double = 0
    @Published var incomeTotalMonth: Double = 0
    @Published var expenseTotalYear: Double = 0
    @Published var incomeTotalYear: Double = 0
    @Published var expenseTotalAll: Double = 0
    @Published var incomeTotalAll: Double = 0
}
