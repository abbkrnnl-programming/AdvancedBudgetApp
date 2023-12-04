//
//  CategoriesView.swift
//  MyPersonalBudgetApp
//
//  Created by Абубакир on 29.11.2023.
//

import SwiftUI
import SwiftData

struct CategoriesView: View {
    @Environment(\.modelContext) var context
    
    @Query var transactionCategories: [TransactionCategory] = []
    
    @State var showSheet = false
    @State var income: Bool = false
    
    var body: some View {
        NavigationView{
            List{
                Section(income ? "Income Categories":"Expense Categories"){
                    ForEach(transactionCategories){ category in
                        if category.income == income {
                            HStack(alignment: .center){
                                Text(category.emoji + " " + category.title)
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button {
                                    let transactions = category.transactions ?? []
                                    for transaction in transactions {
                                        context.delete(transaction)
                                    }
                                    context.delete(category)
                                } label: {
                                    Image(systemName: "trash")
                                }
                                .tint(.red)
                            }
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing:
                                    Button(action: {
                showSheet.toggle()
            }, label: {
                Text("+ New")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding(6)
                    .padding(.horizontal, 8)
                    .background(Color("lightBackColor").cornerRadius(100))
            }))
            .toolbar{
                ToolbarItem(placement: .topBarLeading) {
                    HStack(spacing: 0){
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
                                }
                            }
                    }
                    .padding(3)
                    .overlay(Capsule().stroke(Color("lightBackColor").opacity(0.5), lineWidth: 1.3))
                }
            }
        }
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showSheet) {
            AddTransactionCategoryView(income: $income)
                .presentationDetents([.height(250)])
                .presentationCornerRadius(20)
        }
    }
}

#Preview {
    CategoriesView()
}
