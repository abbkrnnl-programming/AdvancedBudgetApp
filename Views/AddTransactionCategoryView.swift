//
//  AddTransactionCategoryView.swift
//  MyPersonalBudgetApp
//
//  Created by Абубакир on 29.11.2023.
//

import SwiftUI
import SwiftData
import EmojiPicker

struct AddTransactionCategoryView: View {
    @Environment(\.modelContext) var context
    @Environment(\.dismiss) private var dismiss
    
    @Binding var income: Bool
    @State var emoji: Emoji? = nil
    @State var emojiVal: String = ""
    @State var title: String = ""
    @State var displayEmojiPicker: Bool = false
    @State var showAlert = false
    
    var body: some View {
        NavigationStack{
            ZStack{
                Color(red: 15/255, green: 15/255, blue: 15/255)
                    .ignoresSafeArea(.all)
                
                VStack{
                    Button(action: {
                        displayEmojiPicker.toggle()
                    }, label: {
                        Text(emoji?.value ?? "")
                            .font(.system(size: 50))
                            .frame(width: 80, height: 80)
                            .background(Color("lightBackColor").cornerRadius(10))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color(red: 80/255, green: 80/255, blue: 80/255), lineWidth:2)
                            )
                    })
                    .padding(.vertical)
                    
                    HStack{
                        TextField("Category Name", text: $title)
                            .background(Color("lightBackColor").cornerRadius(10))
                            .padding(.leading)
                        
                        Button(action: {
                            //Save Category
                            if !checkSaveAvailable(){
                                showAlert.toggle()
                            } else{
                                emojiVal = emoji?.value ?? ""
                                let category: TransactionCategory = TransactionCategory(title: title, emoji: emojiVal, income: income)
                                context.insert(category)
                                dismiss()
                            }
                        }, label: {
                            Image(systemName: "plus")
                                .font(.headline)
                                .foregroundStyle(.black)
                                .padding()
                                .background(Color.white.cornerRadius(10))
                                .padding(.trailing)
                        })
                    }
                    .padding(.vertical)
                }
                .textFieldStyle(CustomTextField())
                .navigationBarTitle("Add Category")
                .navigationBarTitleDisplayMode(.inline)
                .padding(.vertical)
            }
        }
        .preferredColorScheme(.dark)
        .sheet(isPresented: $displayEmojiPicker){
            EmojiPickerView(selectedEmoji: $emoji)
                .navigationTitle("Emojis")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    func checkSaveAvailable() -> Bool{
        if emoji != nil && title.count >= 2{
            return true
        }
        return false
    }
}

#Preview {
    AddTransactionCategoryView(income: .constant(true))
}
