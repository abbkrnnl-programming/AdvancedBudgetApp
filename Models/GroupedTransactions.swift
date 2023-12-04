//
//  GroupedTransactions.swift
//  MyPersonalBudgetApp
//
//  Created by Абубакир on 29.11.2023.
//

import Foundation
import SwiftData

struct GroupedTransactions: Identifiable {
    var id: UUID = .init()
    var date: Date
    var transactions: [Transaction]
    
    var groupTitle: String{
        let calendar = Calendar.current
        
        if calendar.isDateInToday(date){
            return "Today"
        }
        return date.formatted(.dateTime.weekday().day().month())
    }
}
