//
//  AddTransactionView.swift
//  MyPersonalBudgetApp
//
//  Created by Абубакир on 29.11.2023.
//

import SwiftUI
import SwiftData

struct AddTransactionView: View {
    @Environment(\.modelContext) var context
    @Environment(\.dismiss) var dismiss
    
    @Query var transactionCategories: [TransactionCategory] = []
    
    @Binding var selectedTabView: Int
    @State var title: String = ""
    @State var income = false
    @State var isPressed = false
    @State var amountString: String = "0"
    @State var date: Date = Date()
    @State var transactionCategory: TransactionCategory? = nil
    @State var showCategoryPicker = false
    @State var showAlarm = false
    
    @State var horizontalPadding: Bool = false
    @State var counter: Int = 0
    let tmp = "Add note"
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    Spacer()
                    VStack(alignment: .center) {
                        Button {
                            if amountString.count < 2{
                                amountString = "0"
                            } else{
                                amountString.removeLast()
                            }
                            counter = max(0, counter-1)
                        } label: {
                            Image(systemName: "delete.left.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 20, height: 20)
                                .fontWeight(.semibold)
                                .foregroundColor(.white.opacity(0.5))
                                .padding(10)
                                .background(Color("lightBackColor").cornerRadius(100))
                        }
                        .offset(CGSize(width: UIScreen.screenWidth/2-45, height: 60))
                        .opacity(isDisabled() ? 1.0:0)
                        
                        HStack(alignment: .center){
                            Text("€")
                                .font(.system(size: 20))
                            Text(amountString)
                                .font(amountString.count < 9 ? .system(size: 40):.system(size: 28))
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity, minHeight: 70)
                        
                        TextFieldDynamicWidth(title: "Add Note", text: $title)
                            .textFieldStyle(CustomTextField())
                            .padding(.top, 6)
                    }
                    .frame(maxWidth: .infinity)
                    
                    Spacer()
                    Spacer()
                    
                    //Date and Category Picker
                    HStack(){
                        DatePicker(selection: $date, displayedComponents: .date) {
                            Image(systemName: "calendar")
                        }
                        //.colorMultiply(Color.white)
                        .frame(width: 150)
                        .accentColor(.black)
                        
                        Spacer()
                        
                        Button {
                            withAnimation {
                                showCategoryPicker.toggle()
                            }
                        } label: {
                            if transactionCategory != nil {
                                let emoji = transactionCategory?.emoji
                                let titleTmp = transactionCategory?.title
                                HStack {
                                    Text(emoji ?? "")
                                    Text(titleTmp ?? "")
                                }
                            } else {
                                HStack {
                                    Image(systemName: "square.grid.2x2.fill")
                                    Text("Category")
                                }
                            }
                        }
                        .foregroundColor(.white)
                        .padding(10)
                        .padding(.horizontal, 5)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color(red: 80/255, green: 80/255, blue: 80/255), lineWidth: 2)
                        )
                    }
                    .padding()
                    
                    //Number Buttons
                    GridView(amountString: $amountString, counter: $counter, isPressed: $isPressed, transactionCategory: $transactionCategory, date: $date, title: $title, income: $income, selectedTab: $selectedTabView, showAlert: $showAlarm)
                }
                .frame(height: UIScreen.screenHeight*0.82)
                .padding()
                .navigationBarTitleDisplayMode(.inline)
                .toolbar{
                    ToolbarItem(placement: .topBarLeading) {
                        HStack(spacing: 0) {
                            Text("Expense")
                                .font(.headline)
                                .padding(6)
                                .padding(.horizontal, 8)
                                .background {
                                    if !income{
                                        Capsule()
                                            .fill(Color("lightBackColor"))
                                    }
                                }
                                .onTapGesture {
                                    withAnimation(.easeInOut(duration: 0.35)) {
                                        income = false
                                        title = ""
                                        isPressed = false
                                        amountString = "0"
                                        date = Date()
                                        transactionCategory = nil
                                        showCategoryPicker = false
                                    }
                                }
                            
                            Text("Income")
                                .font(.headline)
                                .padding(6)
                                .padding(.horizontal, 8)
                                .background {
                                    if income{
                                        Capsule()
                                            .fill(Color("lightBackColor"))
                                    }
                                }
                                .onTapGesture {
                                    withAnimation(.easeInOut(duration: 0.35)) {
                                        income = true
                                        title = ""
                                        isPressed = false
                                        amountString = "0"
                                        date = Date()
                                        transactionCategory = nil
                                        showCategoryPicker = false
                                    }
                                }
                        }
                        .padding(3)
                        .overlay(Capsule().stroke(Color("lightBackColor").opacity(0.5), lineWidth: 1.3))
                    }
                    
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: {
                            selectedTabView = 0
                            dismiss()
                        }, label: {
                            Image(systemName: "xmark")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 16, height: 16)
                                .fontWeight(.semibold)
                                .foregroundColor(.white.opacity(0.5))
                                .padding(10)
                                .background(Color("lightBackColor").cornerRadius(100))
                        })
                        .padding(3)
                    }
                }
            }
            .scrollDisabled(true)
            .overlay {
                Group{
                    if showCategoryPicker == true {
                        CategoryPickerView(income: $income, showPickerView: $showCategoryPicker, transactionCategory: $transactionCategory, showCategoryPicker: $showCategoryPicker)
                            .offset(x: UIScreen.screenWidth/2-170, y: -155)
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
        .overlay{
            Group{
                if showAlarm {
                    Text("Please Fill All Entries")
                        .foregroundColor(Color.red)
                        .font(.headline)
                        .padding(10)
                        .padding(.horizontal, 5)
                        .background(Color(red: 0.35, green: 0, blue: 0))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                withAnimation(.easeInOut) {
                                    showAlarm = false
                                }
                            }
                        }
                        .offset(x: -UIScreen.screenWidth/4.6, y: -UIScreen.screenHeight/2.32)
                }
            }
        }
        .onChange(of: selectedTabView) { old, new in
            dismiss()
        }
    }
    
    func isDisabled() -> Bool{
        return amountString != "0"
    }
}

struct CategoryPickerView: View {
    @Environment(\.modelContext) var context
    @Environment(\.dismiss) var dismiss
    
    @Query var transactionCategories: [TransactionCategory] = []
    @Binding var income: Bool
    @Binding var showPickerView: Bool
    
    @Binding var transactionCategory: TransactionCategory?
    @Binding var showCategoryPicker: Bool
    
    var body: some View {
        ScrollView {
            VStack (alignment: .trailing, spacing: 8) {
                Spacer()
                ForEach(transactionCategories) { category in
                    if category.income == income {
                        HStack {
                            Spacer()
                            HStack {
                                Text(category.emoji)
                                Text(category.title)
                            }
                            .foregroundColor(.white)
                            .padding(10)
                            .padding(.horizontal, 5)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color(red: 80/255, green: 80/255, blue: 80/255), lineWidth: 2)
                            )
                            .background(Color.black.cornerRadius(10))
                            .onTapGesture {
                                withAnimation(.easeInOut){
                                    transactionCategory = category
                                    showCategoryPicker = false
                                }
                            }
                        }
                        .frame(width: 300)
                    }
                }
            }
            .rotationEffect(Angle(degrees: 180))
            .padding(.horizontal)
        }
        .scrollIndicators(.hidden)
        .frame(height: 160)
        .rotationEffect(Angle(degrees: 180))
    }
}

struct GridView: View {
    @Environment(\.modelContext) var context
    @Environment(\.dismiss) var dismiss
    
    var grid = [["1", "2", "3"], ["4", "5", "6"], ["7", "8", "9"], [".", "0", "checkmark.square.fill"]]
    @Binding var amountString: String
    @Binding var counter: Int
    @Binding var isPressed: Bool
    @Binding var transactionCategory: TransactionCategory?
    @Binding var date: Date
    @Binding var title: String
    @Binding var income: Bool
    @Binding var selectedTab: Int
    @Binding var showAlert: Bool
    
    var body: some View {
        ForEach(grid, id: \.self) { row in
            HStack(alignment: .center) {
                ForEach(row, id: \.self) { cell in
                    Button {
                        if cell.count > 1 {
                            if checkSubmit() {
                                let amount = Double(amountString)
                                let transaction = Transaction(
                                    title: title,
                                    amount: amount ?? 0.01,
                                    date: date,
                                    income: income,
                                    category: transactionCategory)
                                selectedTab = 1
                                dismiss()
                                context.insert(transaction)
                            } else {
                                withAnimation(.easeInOut) {
                                    showAlert.toggle()
                                }
                                print(showAlert.description)
                            }
                        } else if amountString == "0"{
                            if cell == "."{
                                amountString += cell
                            } else if cell.count < 2{
                                amountString = cell
                            }
                        }
                        else{
                            if cell == "." && amountString.contains("."){
                                
                            } else if cell.count > 1{
                                
                            } else {
                                if amountString.contains(".") && counter < 2{
                                    amountString += cell
                                    counter += 1
                                } else if !amountString.contains("."){
                                    amountString += cell
                                }
                            }
                        }
                    } label: {
                        if cell.count < 2 {
                            Text(cell)
                                .font(.system(size: 40))
                                .frame(width: UIScreen.screenWidth/3.3, height: UIScreen.screenWidth/5.5)
                                .background(Color("lightBackColor").cornerRadius(15))
                                .foregroundStyle(Color.white)
                                .padding(.horizontal, cell == "2" || cell == "5" || cell == "8" || cell == "0" ? 10:0)
                                .padding(.vertical, 3)
                                .scaleEffect(isPressed ? 0.9 : 1.0)
                                .opacity(isPressed ? 0.6 : 1.0)
                                .animation(.easeInOut, value: isPressed)
                        } else {
                            Image(systemName: cell)
                                .font(.system(size: 40))
                                .frame(width: UIScreen.screenWidth/3.3, height: UIScreen.screenWidth/5.5)
                                .background(Color.white.cornerRadius(15))
                                .foregroundStyle(Color.black)
                                .scaleEffect(isPressed ? 0.9 : 1.0)
                                .opacity(isPressed ? 0.6 : 1.0)
                                .animation(.easeInOut, value: isPressed)
                        }
                    }
                    .buttonStyle(PressEffectButtonStyle())
                    .disabled(cell == "." && amountString.contains("."))
                    .disabled(amountString.count > 10)
                }
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    func checkSubmit() -> Bool{
        if amountString != "0" && amountString != "0." && !title.isEmpty && transactionCategory != nil {
            return true
        }
        return false
    }
}

#Preview {
    AddTransactionView(selectedTabView: .constant(2))
}
