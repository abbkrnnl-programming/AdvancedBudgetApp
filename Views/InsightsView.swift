//
//  InsightsView.swift
//  MyPersonalBudgetApp
//
//  Created by Абубакир on 29.11.2023.
//

import SwiftUI
import SwiftData
import Charts

struct InsightsView: View {
    @Environment(\.modelContext) var context
    @Query(sort: \Transaction.date, order: .reverse) var transactions: [Transaction]
    
    @StateObject var budgetModel = BudgetModel()
    
    @State var groupedTransactions: [GroupedTransactions] = []
    @State var income = false
    @State var range = "week"
    @State var showPopover = false
    var body: some View {
        VStack {
            // Header
            HStack {
                HeaderView(showPopover: $showPopover, range: $range)
            }
            .padding()
            
            //Total+Range
            HStack{
                TotalRange(range: $range, income: $income).environmentObject(budgetModel)
            }
            .padding()
            .padding(.horizontal)
            
            //Income and Expense data
            HStack{
                HStack {
                    Image(systemName: "arrow.up.forward")
                        .font(.largeTitle)
                        .fontWeight(.semibold)
                        .foregroundStyle(.green)
                        .padding(8)
                        .background(Color.green.opacity(0.2))
                        .cornerRadius(15)
                    
                    VStack(alignment: .leading){
                        Text("Income")
                            .font(.headline)
                            .foregroundStyle(.white.opacity(0.5))
                        
                        if range == "week" {
                            Text("€\(budgetModel.incomeTotalWeek, specifier: "%.2f")")
                                .font(budgetModel.incomeTotalWeek < 1000 ? .title2:.headline)
                                .fontWeight(.semibold)
                        } else if range == "month" {
                            Text("€\(budgetModel.incomeTotalMonth, specifier: "%.2f")")
                                .font(budgetModel.incomeTotalMonth < 1000 ? .title2:.headline)
                                .fontWeight(.semibold)
                        } else {
                            Text("€\(budgetModel.incomeTotalYear, specifier: "%.2f")")
                                .font(budgetModel.incomeTotalYear < 1000 ? .title2:.headline)
                                .fontWeight(.semibold)
                        }
                    }
                }
                .padding(.vertical, 10)
                .padding(.horizontal)
                .background(Color("darkBackColor").cornerRadius(24))
                .overlay{
                    if income{
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(Color(red: 80/255, green: 80/255, blue: 80/255), lineWidth:2)
                    }
                }
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.15)) {
                        income = true
                    }
                }
                
                
                Spacer()
                HStack {
                    Image(systemName: "arrow.down.forward")
                        .font(.largeTitle)
                        .fontWeight(.semibold)
                        .foregroundStyle(.red)
                        .padding(8)
                        .background(Color.red.opacity(0.2))
                        .cornerRadius(15)
                    
                    VStack(alignment: .leading){
                        Text("Expense")
                            .font(.headline)
                            .foregroundStyle(.white.opacity(0.5))
                        
                        if range == "week" {
                            Text("€\(budgetModel.expenseTotalWeek, specifier: "%.2f")")
                                .font(budgetModel.expenseTotalWeek < 1000 ? .title2:.headline)
                                .fontWeight(.semibold)
                        } else if range == "month" {
                            Text("€\(budgetModel.expenseTotalMonth, specifier: "%.2f")")
                                .font(budgetModel.expenseTotalMonth < 1000 ? .title2:.headline)
                                .fontWeight(.semibold)
                        } else {
                            Text("€\(budgetModel.expenseTotalYear, specifier: "%.2f")")
                                .font(budgetModel.expenseTotalYear < 1000 ? .title2:.headline)
                                .fontWeight(.semibold)
                        }
                    }
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 10)
                .background(Color("darkBackColor").cornerRadius(24))
                .overlay{
                    if !income{
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(Color(red: 80/255, green: 80/255, blue: 80/255), lineWidth:2)
                    }
                }
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.15)) {
                        income = false
                    }
                }
            }
            .padding(.horizontal)
            
            //Chart
            if range == "week"{
                WeekChart(income: $income)
                    .padding()
                    .frame(height: 200)
            } else if range == "month" {
                MonthChart(income: $income)
                    .padding()
                    .frame(height: 200)
            } else {
                YearChart(income: $income)
                    .padding()
                    .frame(height: 200)
            }
            
            //Bar Chart
            BarChart(income: $income, range: $range)
        }
        .onChange(of: transactions) { oldValue, newValue in
            updateIncomeTotal()
            updateExpenseTotal()
            updateGroupedTransactions()
        }
        .onAppear() {
            updateIncomeTotal()
            updateExpenseTotal()
            updateGroupedTransactions()
        }
    }
    
    func updateGroupedTransactions(){
        let calendar = Calendar.current
        //Making dictionary [date:transactions]
        let dict = Dictionary(grouping: transactions) { transaction in
            let dateComponents = calendar.dateComponents([.day, .month, .year], from: transaction.date)
            return dateComponents
        }
        //Sorting dict in descending order
        let sortedDict = dict.sorted {
            let date1 = calendar.date(from: $0.key) ?? .init()
            let date2 = calendar.date(from: $1.key) ?? .init()
            return calendar.compare(date1, to: date2, toGranularity: .day) == .orderedDescending
        }
        //Updating groupedTransactions
        groupedTransactions = sortedDict.compactMap({ dict in
            let date = Calendar.current.date(from: dict.key) ?? .init()
            return .init(date: date, transactions: dict.value)
        })
    }
    
    func updateIncomeTotal(){
        budgetModel.incomeTotalYear = 0
        budgetModel.incomeTotalAll = 0
        budgetModel.incomeTotalMonth = 0
        budgetModel.incomeTotalWeek = 0
        let calendar = Calendar.current
        for transaction in transactions {
            if transaction.income {
                if calendar.component(.weekOfYear, from: Date()) == calendar.component(.weekOfYear, from: transaction.date) {
                    budgetModel.incomeTotalWeek += transaction.amount
                    if calendar.component(.month, from: Date()) == calendar.component(.month, from: transaction.date) {
                        budgetModel.incomeTotalMonth += transaction.amount
                    }
                    if calendar.component(.year, from: Date()) == calendar.component(.year, from: transaction.date) {
                        budgetModel.incomeTotalYear += transaction.amount
                    }
                    budgetModel.incomeTotalAll += transaction.amount
                } else if calendar.component(.month, from: Date()) == calendar.component(.month, from: transaction.date) {
                    budgetModel.incomeTotalMonth += transaction.amount
                    if calendar.component(.year, from: Date()) == calendar.component(.year, from: transaction.date) {
                        budgetModel.incomeTotalYear += transaction.amount
                    }
                    budgetModel.incomeTotalAll += transaction.amount
                } else if calendar.component(.year, from: Date()) == calendar.component(.year, from: transaction.date) {
                    budgetModel.incomeTotalYear += transaction.amount
                    budgetModel.incomeTotalAll += transaction.amount
                } else {
                    budgetModel.incomeTotalAll += transaction.amount
                }
            }
        }
    }
    
    func updateExpenseTotal(){
        budgetModel.expenseTotalYear = 0
        budgetModel.expenseTotalAll = 0
        budgetModel.expenseTotalMonth = 0
        budgetModel.expenseTotalWeek = 0
        let calendar = Calendar.current
        for transaction in transactions {
            if !transaction.income {
                if calendar.component(.weekOfYear, from: Date()) == calendar.component(.weekOfYear, from: transaction.date) {
                    budgetModel.expenseTotalWeek += transaction.amount
                    if calendar.component(.month, from: Date()) == calendar.component(.month, from: transaction.date) {
                        budgetModel.expenseTotalMonth += transaction.amount
                    }
                    if calendar.component(.year, from: Date()) == calendar.component(.year, from: transaction.date) {
                        budgetModel.expenseTotalYear += transaction.amount
                    }
                    budgetModel.expenseTotalAll += transaction.amount
                } else if calendar.component(.month, from: Date()) == calendar.component(.month, from: transaction.date) {
                    if calendar.component(.year, from: Date()) == calendar.component(.year, from: transaction.date){
                        budgetModel.expenseTotalMonth += transaction.amount
                    }
                    budgetModel.expenseTotalYear += transaction.amount
                    budgetModel.expenseTotalAll += transaction.amount
                } else if calendar.component(.year, from: Date()) == calendar.component(.year, from: transaction.date) {
                    budgetModel.expenseTotalYear += transaction.amount
                    budgetModel.expenseTotalAll += transaction.amount
                } else {
                    budgetModel.expenseTotalAll += transaction.amount
                }
            }
        }
    }
}

struct HeaderView: View {
    @Binding var showPopover: Bool
    @Binding var range: String

    var body: some View {
        Text("Insights")
            .font(.title)
            .fontWeight(.semibold)
        Spacer()
        HStack {
            Button {
                showPopover.toggle()
            } label: {
                HStack {
                    Text(range + " ")
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12))
                }
                .foregroundStyle(.white)
                .padding(6)
                .overlay (
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(red: 80/255, green: 80/255, blue: 80/255), lineWidth:2)
                )
            }
            .popover(isPresented: $showPopover, attachmentAnchor: .point(.bottom)) {
                RangePickView(range: $range, showPopover: $showPopover)
                    .frame(maxWidth: 130, maxHeight: 200)
                    .presentationCompactAdaptation(.none)
            }
        }
    }
}

struct TotalRange: View {
    @Binding var range: String
    @Binding var income: Bool
    @EnvironmentObject var budgetModel: BudgetModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if range == "week" {
                let date1 = Date().startOfWeek ?? Date()
                let date2 = Date().endOfWeek ?? Date()
                let startWeek = date1.formatted(.dateTime.day().month())
                let endWeek = date2.formatted(.dateTime.day().month())
                Text(startWeek + "-" + endWeek)
                    .textCase(.uppercase)
                    .foregroundStyle(.white.opacity(0.5))
                    .fontWeight(.semibold)
            } else if range == "month" {
                let month = Date().formatted(.dateTime.month().year())
                Text(month)
                    .textCase(.uppercase)
                    .foregroundStyle(.white.opacity(0.5))
                    .fontWeight(.semibold)
            } else {
                let year = Date().formatted(.dateTime.year())
                Text(year)
                    .foregroundStyle(.white.opacity(0.5))
                    .fontWeight(.semibold)
            }
            
            HStack(spacing: 3){
                if range == "week" {
                    Text(budgetModel.incomeTotalWeek >= budgetModel.expenseTotalWeek ? "+€" : "-€")
                        .foregroundStyle(.white.opacity(0.5))
                        .font(abs(budgetModel.incomeTotalWeek - budgetModel.expenseTotalWeek) < 1000 ? .title:.title2)
                        .fontWeight(.semibold)
                    Text("\(abs(budgetModel.incomeTotalWeek - budgetModel.expenseTotalWeek), specifier: "%.2f")")
                        .font(abs(budgetModel.incomeTotalWeek - budgetModel.expenseTotalWeek) < 1000 ? .largeTitle:.title)
                        .fontWeight(.semibold)
                } else if range == "month" {
                    Text(budgetModel.incomeTotalMonth >= budgetModel.expenseTotalMonth ? "+€" : "-€")
                        .foregroundStyle(.white.opacity(0.5))
                        .font(.title)
                        .fontWeight(.semibold)
                    Text("\(abs(budgetModel.incomeTotalMonth - budgetModel.expenseTotalMonth), specifier: "%.2f")")
                        .font(abs(budgetModel.incomeTotalMonth - budgetModel.expenseTotalMonth) < 1000 ? .largeTitle:.title)
                        .fontWeight(.semibold)
                } else{
                    Text(budgetModel.incomeTotalYear >= budgetModel.expenseTotalYear ? "+€" : "-€")
                        .foregroundStyle(.white.opacity(0.5))
                        .font(.title)
                        .fontWeight(.semibold)
                    Text("\(abs(budgetModel.incomeTotalYear - budgetModel.expenseTotalYear), specifier: "%.2f")")
                        .font(abs(budgetModel.incomeTotalYear - budgetModel.expenseTotalYear) < 1000 ? .largeTitle:.title)
                        .fontWeight(.semibold)
                }
            }
        }
        
        Spacer()
        
        VStack(alignment: .trailing, spacing: 10) {
            if range == "week" || range == "month" {
                if !income{
                    Text("Spent/Day")
                        .textCase(.uppercase)
                        .foregroundStyle(.white.opacity(0.5))
                        .fontWeight(.semibold)
                } else {
                    Text("Income/Day")
                        .textCase(.uppercase)
                        .foregroundStyle(.white.opacity(0.5))
                        .fontWeight(.semibold)
                }
            } else {
                if !income{
                    Text("Spent/Month")
                        .textCase(.uppercase)
                        .foregroundStyle(.white.opacity(0.5))
                        .fontWeight(.semibold)
                } else {
                    Text("Income/Month")
                        .textCase(.uppercase)
                        .foregroundStyle(.white.opacity(0.5))
                        .fontWeight(.semibold)
                }
            }
            
            HStack{
                Text("€")
                    .foregroundStyle(.white.opacity(0.5))
                    .font(abs(budgetModel.incomeTotalWeek - budgetModel.expenseTotalWeek) < 1000 ? .title:.title2)
                    .fontWeight(.semibold)
                if !income {
                    if range == "week" {
                        let budget = budgetModel.expenseTotalWeek / 7
                        Text("\(budget, specifier: "%.2f")")
                            .font(abs(budgetModel.incomeTotalWeek - budgetModel.expenseTotalWeek) < 1000 ? .largeTitle:.title)
                            .fontWeight(.semibold)
                    } else if range == "month" {
                        let budget = budgetModel.expenseTotalMonth / 30
                        Text("\(budget, specifier: "%.2f")")
                            .font(abs(budgetModel.incomeTotalMonth - budgetModel.expenseTotalMonth) < 1000 ? .largeTitle:.title)
                            .fontWeight(.semibold)
                    } else{
                        let budget = budgetModel.expenseTotalYear / 12
                        Text("\(budget, specifier: "%.2f")")
                            .font(abs(budgetModel.incomeTotalYear - budgetModel.expenseTotalYear) < 1000 ? .largeTitle:.title)
                            .fontWeight(.semibold)
                    }
                } else {
                    if range == "week" {
                        let budget = budgetModel.incomeTotalWeek / 7
                        Text("\(budget, specifier: "%.2f")")
                            .font(abs(budgetModel.incomeTotalWeek - budgetModel.expenseTotalWeek) < 1000 ? .largeTitle:.title)
                            .fontWeight(.semibold)
                    } else if range == "month" {
                        let budget = budgetModel.incomeTotalMonth / 30
                        Text("\(budget, specifier: "%.2f")")
                            .font(abs(budgetModel.incomeTotalMonth - budgetModel.expenseTotalMonth) < 1000 ? .largeTitle:.title)
                            .fontWeight(.semibold)
                    } else{
                        let budget = budgetModel.incomeTotalYear / 12
                        Text("\(budget, specifier: "%.2f")")
                            .font(abs(budgetModel.incomeTotalYear - budgetModel.expenseTotalYear) < 1000 ? .largeTitle:.title)
                            .fontWeight(.semibold)
                    }
                }
            }
        }
    }
}

struct RangePickView: View {
    @Binding var range: String
    @Binding var showPopover: Bool
    
    var body: some View {
        ScrollView {
            VStack(alignment: .trailing) {
                Button {
                    withAnimation(.easeInOut(duration: 0.15)){
                        range = "week"
                        showPopover = false
                    }
                } label: {
                    HStack {
                        Text("week")
                        Spacer()
                        if range == "week" {
                            Image(systemName: "checkmark")
                        }
                    }
                    .foregroundColor(.white)
                    .frame(width: 110)
                    .padding(6)
                    .background(range == "week" ? Color("lightBackColor"):Color("darkBackColor")).cornerRadius(5)
                }
                
                Button {
                    withAnimation(.easeInOut(duration: 0.15)){
                        range = "month"
                        showPopover = false
                    }
                } label: {
                    HStack {
                        Text("month")
                        Spacer()
                        if range == "month" {
                            Image(systemName: "checkmark")
                        }
                    }
                    .foregroundColor(.white)
                    .frame(width: 110)
                    .padding(6)
                    .background(range == "month" ? Color("lightBackColor"):Color("darkBackColor")).cornerRadius(5)
                }
                
                Button {
                    withAnimation(.easeInOut(duration: 0.15)){
                        range = "year"
                        showPopover = false
                    }
                } label: {
                    HStack {
                        Text("year")
                        Spacer()
                        if range == "year" {
                            Image(systemName: "checkmark")
                        }
                    }
                    .foregroundColor(.white)
                    .frame(width: 110)
                    .padding(6)
                    .background(range == "year" ? Color("lightBackColor"):Color("darkBackColor")).cornerRadius(5)
                }
            }
            .padding(6)
            .background(Color("darkBackColor").cornerRadius(10))
        }
    }
}

struct WeekChart: View {
    @Query(sort: \Transaction.date, order: .reverse) var transactions: [Transaction]
    
    @State var weekTransactions: [RangeTransactions] = []
    @Binding var income: Bool
    
    var body: some View {
        Chart(weekTransactions) { groupedTransactions in
            BarMark(x: .value("data", groupedTransactions.date.formatted(.dateTime.weekday())), y: .value("amount", income ? groupedTransactions.incomeAmount:groupedTransactions.expenseAmount))
                .foregroundStyle(.white)
        }
        .onAppear(){
            updateWeekTransactions()
        }
    }
    
    func updateWeekTransactions(){
        // Generate dates for the entire week
        var weekDates: [Date] = []
        if let startOfWeek = Date().startOfWeek {
            for day in 0..<7 {
                if let nextDate = startOfWeek.addingDays(day) {
                    weekDates.append(nextDate)
                }
            }
        }
        
        // Initialize weekIncomes with zero amounts
        weekTransactions = []
        weekTransactions = weekDates.map { date in
            return RangeTransactions(date: date, incomeAmount: 0, expenseAmount: 0)
        }
        
        weekTransactions.indices.forEach { index in
            for transaction in transactions {
                if Calendar.current.isDate(weekTransactions[index].date, inSameDayAs: transaction.date) {
                    if transaction.income {
                        weekTransactions[index].incomeAmount += transaction.amount
                    } else {
                        weekTransactions[index].expenseAmount += transaction.amount
                    }
                }
            }
        }
    }
}

struct MonthChart: View {
    @Query(sort: \Transaction.date, order: .reverse) var transactions: [Transaction]
    
    @State var monthTransactions: [RangeTransactions] = []
    @Binding var income: Bool
    
    var body: some View {
        Chart(monthTransactions) { groupedTransactions in
            BarMark(x: .value("data", groupedTransactions.date, unit: .day), y: .value("amount", income ? groupedTransactions.incomeAmount:groupedTransactions.expenseAmount))
                .foregroundStyle(.white)
        }
        .onAppear(){
            updateMonthTransactions()
        }
    }
    
    
    func updateMonthTransactions(){
        var monthDates: [Date] = []
        if let startOfMonth = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Date())) {
            if let range = Calendar.current.range(of: .day, in: .month, for: startOfMonth) {
                for day in 0..<range.count {
                    if let nextDate = startOfMonth.addingDays(day) {
                        monthDates.append(nextDate)
                    }
                }
            }
        }

        // Initialize monthIncomes with zero amounts
        monthTransactions = monthDates.map { date in
            return RangeTransactions(date: date, incomeAmount: 0, expenseAmount: 0)
        }

        // Update amounts based on actual incomes
        for transaction in transactions {
            if let index = monthTransactions.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: transaction.date) }) {
                if transaction.income {
                    monthTransactions[index].incomeAmount += transaction.amount
                } else {
                    monthTransactions[index].expenseAmount += transaction.amount
                }
            }
        }
    }
}

struct YearChart: View {
    @Query(sort: \Transaction.date, order: .reverse) var transactions: [Transaction]
    
    @State var yearTransactions: [RangeTransactions] = []
    @Binding var income: Bool
    
    var body: some View {
        Chart(yearTransactions) { groupedTransactions in
            BarMark(
                x: .value("data", groupedTransactions.date.formatted(.dateTime.month())),
                y: .value("amount", income ? groupedTransactions.incomeAmount:groupedTransactions.expenseAmount))
                .foregroundStyle(.white)
        }
        .onAppear(){
            updateYearTransactions()
        }
    }
    
    
    func updateYearTransactions(){
        var yearDates: [Date] = []
        if let startOfYear = Calendar.current.date(from: Calendar.current.dateComponents([.year], from: Date())) {
            for month in 1...12 {
                if let nextDate = Calendar.current.date(bySetting: .month, value: month, of: startOfYear) {
                    yearDates.append(nextDate)
                }
            }
        }

        // Initialize monthIncomes with zero amounts
        yearTransactions = yearDates.map { date in
            return RangeTransactions(date: date, incomeAmount: 0, expenseAmount: 0)
        }

        // Update amounts based on actual incomes
        for transaction in transactions {
            if let index = yearTransactions.firstIndex(where: { Calendar.current.isDate($0.date, equalTo: transaction.date, toGranularity: .month) }) {
                if transaction.income {
                    yearTransactions[index].incomeAmount += transaction.amount
                } else {
                    yearTransactions[index].expenseAmount += transaction.amount
                }
            }
        }
    }
}

struct BarChart: View {
    @Query var transactionCategories: [TransactionCategory] = []
    
    @Binding var income: Bool
    @Binding var range: String
    
    @State var barTransactions: [BarTransaction] = []
    
    @State var totalIncome: Double = 0.0
    @State var totalExpense: Double = 0.0
    
    let rgbColors = [
        Color(red: 169/255, green: 179/255, blue: 136/255),
        Color(red: 223/255, green: 120/255, blue: 87/255),
        Color(red: 97/255, green: 163/255, blue: 186/255),
        Color(red: 249/255, green: 243/255, blue: 204/255),
        Color(red: 180/255, green: 189/255, blue: 255/255),
        Color(red: 255/255, green: 255/255, blue: 201/255),
        Color(red: 162/255, green: 197/255, blue: 121/255),
        Color(red: 142/255, green: 205/255, blue: 221/255),
        Color(red: 237/255, green: 158/255, blue: 214/255),
        Color(red: 255/255, green: 199/255, blue: 199/255),
        Color(red: 109/255, green: 185/255, blue: 239/255),
        Color(red: 48/255, green: 128/255, blue: 208/255),
        Color(red: 220/255, green: 134/255, blue: 134/255),
        Color(red: 154/255, green: 208/255, blue: 194/255),
        Color(red: 162/255, green: 197/255, blue: 121/255),
        Color(red: 210/255, green: 222/255, blue: 50/255),
        Color(red: 255/255, green: 197/255, blue: 197/255),
        Color(red: 199/255, green: 220/255, blue: 167/255),
        Color(red: 249/255, green: 243/255, blue: 204/255),
        Color(red: 169/255, green: 179/255, blue: 136/255),
        Color(red: 223/255, green: 120/255, blue: 87/255),
        Color(red: 97/255, green: 163/255, blue: 186/255),
        Color(red: 249/255, green: 243/255, blue: 204/255),
        Color(red: 180/255, green: 189/255, blue: 255/255),
        Color(red: 255/255, green: 255/255, blue: 201/255),
        Color(red: 162/255, green: 197/255, blue: 121/255),
        Color(red: 142/255, green: 205/255, blue: 221/255),
        Color(red: 237/255, green: 158/255, blue: 214/255),
        Color(red: 255/255, green: 199/255, blue: 199/255),
        Color(red: 109/255, green: 185/255, blue: 239/255),
        Color(red: 48/255, green: 128/255, blue: 208/255),
        Color(red: 220/255, green: 134/255, blue: 134/255),
        Color(red: 154/255, green: 208/255, blue: 194/255),
        Color(red: 162/255, green: 197/255, blue: 121/255),
        Color(red: 210/255, green: 222/255, blue: 50/255),
        Color(red: 255/255, green: 197/255, blue: 197/255),
        Color(red: 199/255, green: 220/255, blue: 167/255),
        Color(red: 249/255, green: 243/255, blue: 204/255),
        Color(red: 169/255, green: 179/255, blue: 136/255),
        Color(red: 223/255, green: 120/255, blue: 87/255),
        Color(red: 97/255, green: 163/255, blue: 186/255),
        Color(red: 249/255, green: 243/255, blue: 204/255),
        Color(red: 180/255, green: 189/255, blue: 255/255),
        Color(red: 255/255, green: 255/255, blue: 201/255),
        Color(red: 162/255, green: 197/255, blue: 121/255),
        Color(red: 142/255, green: 205/255, blue: 221/255),
        Color(red: 237/255, green: 158/255, blue: 214/255),
        Color(red: 255/255, green: 199/255, blue: 199/255),
        Color(red: 109/255, green: 185/255, blue: 239/255),
        Color(red: 48/255, green: 128/255, blue: 208/255),
        Color(red: 220/255, green: 134/255, blue: 134/255),
        Color(red: 154/255, green: 208/255, blue: 194/255),
        Color(red: 162/255, green: 197/255, blue: 121/255),
        Color(red: 210/255, green: 222/255, blue: 50/255),
        Color(red: 255/255, green: 197/255, blue: 197/255),
        Color(red: 199/255, green: 220/255, blue: 167/255),
        Color(red: 249/255, green: 243/255, blue: 204/255),
        Color(red: 169/255, green: 179/255, blue: 136/255),
        Color(red: 223/255, green: 120/255, blue: 87/255),
        Color(red: 97/255, green: 163/255, blue: 186/255),
        Color(red: 249/255, green: 243/255, blue: 204/255),
        Color(red: 180/255, green: 189/255, blue: 255/255),
        Color(red: 255/255, green: 255/255, blue: 201/255),
        Color(red: 162/255, green: 197/255, blue: 121/255),
        Color(red: 142/255, green: 205/255, blue: 221/255),
        Color(red: 237/255, green: 158/255, blue: 214/255),
        Color(red: 255/255, green: 199/255, blue: 199/255),
        Color(red: 109/255, green: 185/255, blue: 239/255),
        Color(red: 48/255, green: 128/255, blue: 208/255),
        Color(red: 220/255, green: 134/255, blue: 134/255),
        Color(red: 154/255, green: 208/255, blue: 194/255),
        Color(red: 162/255, green: 197/255, blue: 121/255),
        Color(red: 210/255, green: 222/255, blue: 50/255),
        Color(red: 255/255, green: 197/255, blue: 197/255),
        Color(red: 199/255, green: 220/255, blue: 167/255),
        Color(red: 249/255, green: 243/255, blue: 204/255),
        Color(red: 169/255, green: 179/255, blue: 136/255),
        Color(red: 223/255, green: 120/255, blue: 87/255),
        Color(red: 97/255, green: 163/255, blue: 186/255),
        Color(red: 249/255, green: 243/255, blue: 204/255),
        Color(red: 180/255, green: 189/255, blue: 255/255),
        Color(red: 255/255, green: 255/255, blue: 201/255),
        Color(red: 162/255, green: 197/255, blue: 121/255),
        Color(red: 142/255, green: 205/255, blue: 221/255),
        Color(red: 237/255, green: 158/255, blue: 214/255),
        Color(red: 255/255, green: 199/255, blue: 199/255),
        Color(red: 109/255, green: 185/255, blue: 239/255),
        Color(red: 48/255, green: 128/255, blue: 208/255),
        Color(red: 220/255, green: 134/255, blue: 134/255),
        Color(red: 154/255, green: 208/255, blue: 194/255),
        Color(red: 162/255, green: 197/255, blue: 121/255),
        Color(red: 210/255, green: 222/255, blue: 50/255),
        Color(red: 255/255, green: 197/255, blue: 197/255),
        Color(red: 199/255, green: 220/255, blue: 167/255),
        Color(red: 249/255, green: 243/255, blue: 204/255)
    ]
    
    var body: some View {
        VStack (alignment: .center){
            Color.clear
                .frame(maxWidth: UIScreen.screenWidth*0.9, maxHeight: 35)
                .overlay{
                    HStack(spacing: 5) {
                        ForEach(barTransactions.indices, id: \.self) { index in
                            if income && barTransactions[index].incomeAmount > 0 {
                                Rectangle()
                                    .frame(width: barTransactions[index].incomeAmount/totalIncome*UIScreen.screenWidth*0.8)
                                    .foregroundColor(rgbColors[index % rgbColors.count])
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            } else if !income && barTransactions[index].expenseAmount > 0 {
                                Rectangle()
                                    .frame(width: barTransactions[index].expenseAmount/totalExpense*UIScreen.screenWidth*0.8)
                                    .foregroundColor(rgbColors[index % rgbColors.count])
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                        }
                    }
                }
                .onChange(of: range, { oldValue, newValue in
                    updateGroupedTransactions()
                })
                .onAppear() {
                    updateGroupedTransactions()
                }
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .frame(maxWidth: .infinity)
        
        ScrollView(.horizontal) {
            HStack(spacing: 15) {
                ForEach(barTransactions.indices, id: \.self) { index in
                    if income && barTransactions[index].incomeAmount > 0 {
                        HStack {
                            Rectangle()
                                .frame(width: 10, height: 10)
                                .foregroundColor(rgbColors[index % rgbColors.count])
                                .clipShape(RoundedRectangle(cornerRadius: 3))
                            
                            Text("\(barTransactions[index].title)")
                                .font(.headline)
                            
                            Text("\(barTransactions[index].incomeAmount*100/totalIncome, specifier: "%.2f")%")
                                .foregroundStyle(.white.opacity(0.65))
                                .fontWeight(.semibold)
                        }
                    } else if !income && barTransactions[index].expenseAmount > 0 {
                        HStack {
                            Rectangle()
                                .frame(width: 10, height: 10)
                                .foregroundColor(rgbColors[index % rgbColors.count])
                                .clipShape(RoundedRectangle(cornerRadius: 3))
                            
                            Text("\(barTransactions[index].title)")
                                .font(.headline)
                            
                            Text("\(barTransactions[index].expenseAmount*100/totalExpense, specifier: "%.2f")%")
                                .foregroundStyle(.white.opacity(0.65))
                                .fontWeight(.semibold)
                        }
                    }
                }
            }
            .padding()
            .padding(.horizontal)
        }
    }
    
    func updateGroupedTransactions() {
        barTransactions = []
        totalIncome = 0
        totalExpense = 0
        for transactionCategory in transactionCategories {
            let title = transactionCategory.title
            var tmp = BarTransaction(title: title, incomeAmount: 0.0, expenseAmount: 0.0)
            let transactions = transactionCategory.transactions ?? []
            for transaction in transactions {
                if range == "week" {
                    if Calendar.current.isDate(transaction.date, equalTo: Date(), toGranularity: .weekOfYear) {
                        if transaction.income {
                            tmp.incomeAmount += transaction.amount
                            totalIncome += transaction.amount
                        } else {
                            tmp.expenseAmount += transaction.amount
                            totalExpense += transaction.amount
                        }
                    }
                } else if range == "month" {
                    if Calendar.current.isDate(transaction.date, equalTo: Date(), toGranularity: .month) {
                        if transaction.income {
                            tmp.incomeAmount += transaction.amount
                            totalIncome += transaction.amount
                        } else {
                            tmp.expenseAmount += transaction.amount
                            totalExpense += transaction.amount
                        }
                    }
                } else {
                    if Calendar.current.isDate(transaction.date, equalTo: Date(), toGranularity: .year) {
                        if transaction.income {
                            tmp.incomeAmount += transaction.amount
                            totalIncome += transaction.amount
                        } else {
                            tmp.expenseAmount += transaction.amount
                            totalExpense += transaction.amount
                        }
                    }
                }
            }
            barTransactions += [tmp]
        }
    }
}

struct BarTransaction: Identifiable {
    var id: UUID = .init()
    var title: String
    var incomeAmount: Double
    var expenseAmount: Double
}

struct RangeTransactions: Identifiable {
    var id: UUID = .init()
    var date: Date
    var incomeAmount: Double
    var expenseAmount: Double
}


#Preview {
    InsightsView()
}
