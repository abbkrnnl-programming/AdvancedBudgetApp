//
//  NetView.swift
//  MyPersonalBudgetApp
//
//  Created by Абубакир on 29.11.2023.
//

import SwiftUI
import SwiftData

struct NetView: View {
    @Environment(\.modelContext) var context
    
    @Query(sort: \Transaction.date, order: .reverse) var transactions: [Transaction]
    
    @State var groupedTransactions: [GroupedTransactions] = []
    @State var income = false
    
    @State var showRangePicker = false
    @State var range = 0
    
    @StateObject var budgetModel = BudgetModel()
    
    var body: some View {
        NavigationView {
            //Container
            VStack {
                // Net total and Range Picker
                VStack {
                    //Range Picker
                    HStack {
                        Text("Net Total")
                            .font(.title3)
                            .fontWeight(.semibold)
                        //Range Picker
                        Button {
                            withAnimation(.easeInOut(duration: 0.15)){
                                showRangePicker.toggle()
                            }
                        } label: {
                            if range == 0 {
                                Text("this week")
                            } else if range == 1 {
                                Text("this month")
                            } else if range == 2 {
                                Text("this year")
                            } else {
                                Text("all time")
                            }
                        }
                        .foregroundStyle(.white)
                        .padding(10)
                        .overlay (
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color(red: 80/255, green: 80/255, blue: 80/255), lineWidth:2)
                        )
                    }
                    
                    //Total Net
                    HStack(spacing: 3){
                        if range == 0 {
                            Text(budgetModel.incomeTotalWeek >= budgetModel.expenseTotalWeek ? "+€" : "-€")
                                .foregroundStyle(.white.opacity(0.5))
                                .font(abs(budgetModel.incomeTotalWeek - budgetModel.expenseTotalWeek) < 1000 ? .system(size: 40):.system(size: 28))
                                .fontWeight(.semibold)
                            Text("\(abs(budgetModel.incomeTotalWeek - budgetModel.expenseTotalWeek), specifier: "%.2f")")
                                .font(abs(budgetModel.incomeTotalWeek - budgetModel.expenseTotalWeek) < 1000 ? .system(size: 60):.system(size: 40))
                                .fontWeight(.semibold)
                        } else if range == 1 {
                            Text(budgetModel.incomeTotalMonth >= budgetModel.expenseTotalMonth ? "+€" : "-€")
                                .foregroundStyle(.white.opacity(0.5))
                                .font(abs(budgetModel.incomeTotalMonth - budgetModel.expenseTotalMonth) < 1000 ? .system(size: 40):.system(size: 28))
                                .fontWeight(.semibold)
                            Text("\(abs(budgetModel.incomeTotalMonth - budgetModel.expenseTotalMonth), specifier: "%.2f")")
                                .font(abs(budgetModel.incomeTotalMonth - budgetModel.expenseTotalMonth) < 1000 ? .system(size: 60):.system(size: 40))
                                .fontWeight(.semibold)
                        } else if range == 2 {
                            Text(budgetModel.incomeTotalYear >= budgetModel.expenseTotalYear ? "+€" : "-€")
                                .foregroundStyle(.white.opacity(0.5))
                                .font(abs(budgetModel.incomeTotalYear - budgetModel.expenseTotalYear) < 1000 ? .system(size: 40):.system(size: 28))
                                .fontWeight(.semibold)
                            Text("\(abs(budgetModel.incomeTotalYear - budgetModel.expenseTotalYear), specifier: "%.2f")")
                                .font(abs(budgetModel.incomeTotalYear - budgetModel.expenseTotalYear) < 1000 ? .system(size: 60):.system(size: 40))
                                .fontWeight(.semibold)
                        } else {
                            Text(budgetModel.incomeTotalAll >= budgetModel.expenseTotalAll ? "+€" : "-€")
                                .foregroundStyle(.white.opacity(0.5))
                                .font(abs(budgetModel.incomeTotalAll - budgetModel.expenseTotalAll) < 1000 ? .system(size: 40):.system(size: 28))
                                .fontWeight(.semibold)
                            Text("\(abs(budgetModel.incomeTotalAll - budgetModel.expenseTotalAll), specifier: "%.2f")")
                                .font(abs(budgetModel.incomeTotalAll - budgetModel.expenseTotalAll) < 1000 ? .system(size: 60):.system(size: 40))
                                .fontWeight(.semibold)
                        }
                    }
                    .padding(.vertical, 0)
                    
                    //IncomeTotal and ExpenseTotal
                    HStack() {
                        if range == 0 {
                            HStack{
                                Spacer()
                                Text("+\(budgetModel.incomeTotalWeek, specifier: "%.2f")")
                                    .foregroundStyle(Color.green)
                                    .font(abs(budgetModel.incomeTotalWeek - budgetModel.expenseTotalWeek) < 1000 ? .title2:.title3)
                                    .fontWeight(.semibold)
                            }
                            .frame(width: UIScreen.screenWidth/2-20)
                            
                            Text("|")
                                .foregroundStyle(Color("lightBackColor"))
                                .font(.title3)
                                .fontWeight(.semibold)
                                .frame(width: 10)
                            
                            HStack{
                                Text("-\(budgetModel.expenseTotalWeek, specifier: "%.2f")")
                                    .foregroundStyle(Color.red)
                                    .font(abs(budgetModel.incomeTotalWeek - budgetModel.expenseTotalWeek) < 1000 ? .title2:.title3)
                                    .fontWeight(.semibold)
                                Spacer()
                            }
                            .frame(width: UIScreen.screenWidth/2-20)
                        } else if range == 1 {
                            HStack{
                                Spacer()
                                Text("+\(budgetModel.incomeTotalMonth, specifier: "%.2f")")
                                    .foregroundStyle(Color.green)
                                    .font(abs(budgetModel.incomeTotalMonth - budgetModel.expenseTotalMonth) < 1000 ? .title2:.title3)
                                    .fontWeight(.semibold)
                            }
                            .frame(width: UIScreen.screenWidth/2-20)
                            
                            Text("|")
                                .foregroundStyle(Color("lightBackColor"))
                                .font(.title3)
                                .fontWeight(.semibold)
                                .frame(width: 10)
                            
                            HStack{
                                Text("-\(budgetModel.expenseTotalMonth, specifier: "%.2f")")
                                    .foregroundStyle(Color.red)
                                    .font(abs(budgetModel.incomeTotalMonth - budgetModel.expenseTotalMonth) < 1000 ? .title2:.title3)
                                    .fontWeight(.semibold)
                                Spacer()
                            }
                            .frame(width: UIScreen.screenWidth/2-20)
                        } else if range == 2 {
                            HStack{
                                Spacer()
                                Text("+\(budgetModel.incomeTotalYear, specifier: "%.2f")")
                                    .foregroundStyle(Color.green)
                                    .font(abs(budgetModel.incomeTotalYear - budgetModel.expenseTotalYear) < 1000 ? .title2:.title3)
                                    .fontWeight(.semibold)
                            }
                            .frame(width: UIScreen.screenWidth/2-20)
                            
                            Text("|")
                                .foregroundStyle(Color("lightBackColor"))
                                .font(.title3)
                                .fontWeight(.semibold)
                                .frame(width: 10)
                            
                            HStack{
                                Text("-\(budgetModel.expenseTotalYear, specifier: "%.2f")")
                                    .foregroundStyle(Color.red)
                                    .font(abs(budgetModel.incomeTotalYear - budgetModel.expenseTotalYear) < 1000 ? .title2:.title3)
                                    .fontWeight(.semibold)
                                Spacer()
                            }
                            .frame(width: UIScreen.screenWidth/2-20)
                        } else {
                            HStack{
                                Spacer()
                                Text("+\(budgetModel.incomeTotalAll, specifier: "%.2f")")
                                    .foregroundStyle(Color.green)
                                    .font(abs(budgetModel.incomeTotalAll - budgetModel.expenseTotalAll) < 1000 ? .title2:.title3)
                                    .fontWeight(.semibold)
                            }
                            .frame(width: UIScreen.screenWidth/2-20)
                            
                            Text("|")
                                .foregroundStyle(Color("lightBackColor"))
                                .font(.title3)
                                .fontWeight(.semibold)
                                .frame(width: 10)
                            
                            HStack{
                                Text("-\(budgetModel.expenseTotalAll, specifier: "%.2f")")
                                    .foregroundStyle(Color.red)
                                    .font(abs(budgetModel.incomeTotalAll - budgetModel.expenseTotalAll) < 1000 ? .title2:.title3)
                                    .fontWeight(.semibold)
                                Spacer()
                            }
                            .frame(width: UIScreen.screenWidth/2-20)
                        }
                    }
                    .padding(.top, 0)
                }
                .padding()
                .overlay {
                    if showRangePicker {
                        RangePickerView(range: $range, showRangePicker: $showRangePicker)
                            .offset(x: 50, y: 50)
                    }
                }
                
                //ExpenseIncomeView(income: $income, groupedExpenses: $groupedExpenses, groupedIncomes: $groupedIncomes)
                ScrollView { GroupedTransactionsView(income: $income, groupedTransactions: $groupedTransactions) }
            }
            .onChange(of: transactions, { oldValue, newValue in
                updateIncomeTotal()
                updateExpenseTotal()
                updateGroupedTransactions()
            })
            .onAppear() {
                updateIncomeTotal()
                updateExpenseTotal()
                updateGroupedTransactions()
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        
                    }, label: {
                        Image(systemName: "magnifyingglass")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .fontWeight(.semibold)
                            .foregroundColor(.white.opacity(0.9))
                    })
                    .padding(3)
                }
            }
        }
        .preferredColorScheme(.dark)
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
        let calendar = Calendar.current
        budgetModel.incomeTotalYear = 0
        budgetModel.incomeTotalAll = 0
        budgetModel.incomeTotalMonth = 0
        budgetModel.incomeTotalWeek = 0
        for transaction in transactions {
            if transaction.income{
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
                    budgetModel.incomeTotalYear += transaction.amount
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
        let calendar = Calendar.current
        budgetModel.expenseTotalYear = 0
        budgetModel.expenseTotalAll = 0
        budgetModel.expenseTotalMonth = 0
        budgetModel.expenseTotalWeek = 0
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
                    budgetModel.expenseTotalMonth += transaction.amount
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

struct GroupedTransactionsView: View {
    @Environment(\.modelContext) var context
    @Binding var income: Bool
    @Binding var groupedTransactions: [GroupedTransactions]
    
    var body: some View {
        ForEach(groupedTransactions.indices, id: \.self) { index in
            VStack(alignment: .leading){
                let title = groupedTransactions[index].groupTitle
                Text(title)
                    .font(.system(size: 16))
                    .fontWeight(.semibold)
                    .textCase(.uppercase)
                    .foregroundStyle(.white.opacity(0.6))
                    .frame(maxWidth: .infinity, alignment: .leading)
                Divider().background(.white.opacity(0.6))
            }
            .padding(.horizontal)
            .padding(.top)
            ForEach(groupedTransactions[index].transactions) { transaction in
                TransactionCellView(transaction: transaction)
            }
        }
    }
}

struct RangePickerView: View {
    @Binding var range: Int
    @Binding var showRangePicker: Bool
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Button {
                    withAnimation(.easeInOut(duration: 0.15)){
                        range = 0
                        showRangePicker = false
                    }
                } label: {
                    HStack {
                        Text("this week")
                        Spacer()
                        if range == 0 {
                            Image(systemName: "checkmark")
                        }
                    }
                    .foregroundColor(.white)
                    .frame(width: 160)
                    .padding(6)
                    .background(range == 0 ? Color("lightBackColor"):Color("darkBackColor")).cornerRadius(5)
                }
                
                Button {
                    withAnimation(.easeInOut(duration: 0.15)){
                        range = 1
                        showRangePicker = false
                    }
                } label: {
                    HStack {
                        Text("this month")
                        Spacer()
                        if range == 1 {
                            Image(systemName: "checkmark")
                        }
                    }
                    .foregroundColor(.white)
                    .frame(width: 160)
                    .padding(6)
                    .background(range == 1 ? Color("lightBackColor"):Color("darkBackColor")).cornerRadius(5)
                }
                
                Button {
                    withAnimation(.easeInOut(duration: 0.15)){
                        range = 2
                        showRangePicker = false
                    }
                } label: {
                    HStack {
                        Text("this year")
                        Spacer()
                        if range == 2 {
                            Image(systemName: "checkmark")
                        }
                    }
                    .foregroundColor(.white)
                    .frame(width: 160)
                    .padding(6)
                    .background(range == 2 ? Color("lightBackColor"):Color("darkBackColor")).cornerRadius(5)
                }
                
                Button {
                    withAnimation(.easeInOut(duration: 0.15)){
                        range = 3
                        showRangePicker = false
                    }
                } label: {
                    HStack {
                        Text("all time")
                        Spacer()
                        if range == 3 {
                            Image(systemName: "checkmark")
                        }
                    }
                    .foregroundColor(.white)
                    .frame(width: 160)
                    .padding(6)
                    .background(range == 3 ? Color("lightBackColor"):Color("darkBackColor")).cornerRadius(5)
                }
            }
            .padding(6)
            .background(Color("darkBackColor").cornerRadius(10))
        }
    }
}

struct TransactionCellView: View {
    var transaction: Transaction
    
    var body: some View {
        let category = transaction.category
        let categoryTitle = category?.title ?? ""
        let emoji = category?.emoji ?? ""
        let transactionTitle = transaction.title
        let amount = transaction.amount
        
        HStack {
            Text(emoji)
                .font(.system(size: 22))
                .padding(6)
                //.background(Color("EmojiBack").cornerRadius(10))
            
            VStack(alignment: .leading) {
                Text(categoryTitle)
                    .font(.system(size: 18))
                    .fontWeight(.semibold)
                Text(transactionTitle)
                    .font(.system(size: 14))
                    .fontWeight(.semibold)
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding(.leading, 6)
            
            Spacer()
            
            Text(transaction.income ? "+€\(amount, specifier: "%.2f")":"-€\(amount, specifier: "%.2f")")
                .font(.system(size: 18))
                .fontWeight(.semibold)
                .foregroundStyle(.white)
        }
        .padding(.horizontal)
    }
    
}

#Preview {
    NetView()
}
