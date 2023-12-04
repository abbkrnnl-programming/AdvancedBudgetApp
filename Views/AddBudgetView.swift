//
//  AddBudgetView.swift
//  MyPersonalBudgetApp
//
//  Created by Абубакир on 01.12.2023.
//

import SwiftUI

struct AddBudgetView: View {
    @AppStorage("overallBudget") var overallBudget: Double?
    @Environment(\.dismiss) var dismiss
    
    @Binding var range: String
    @State var stage = 1
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.05, green: 0.05, blue: 0.05)
                    .ignoresSafeArea(.all)
                
                VStack(alignment: .center) {
                    if stage == 1 {
                        BudgetRangePicker(range: $range, stage: $stage)
                    } else {
                        TargetBudgetView(range: $range, stage: $stage)
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    ZStack{
                        Text(stage == 1 ? "50%":"100%")
                            .font(.headline)
                            .foregroundStyle(stage == 1 ? .white:.green)
                            .padding(8)
                            .padding(.horizontal, 8)
                        
                        RoundedRectangle(cornerRadius: 100)
                            .stroke( stage == 1 ? Color.white.opacity(0.2):Color.green, lineWidth: 3)
                        RoundedRectangle(cornerRadius: 100)
                            .trim(from: 0, to: stage == 1 ? 0.50:1)
                            .stroke( stage == 1 ? Color.white:Color.green, lineWidth: 2)
                    }
                }
                
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        if stage == 1 {
                            dismiss()
                        } else {
                            withAnimation(.bouncy) {
                                stage = 1
                            }
                        }
                    } label: {
                        Image(systemName: stage == 1 ? "xmark" : "chevron.backward")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 14, height: 14)
                            .fontWeight(.semibold)
                            .foregroundColor(.white.opacity(0.5))
                            .padding(10)
                            .background(Color("lightBackColor").cornerRadius(100))
                    }
                    .padding()
                }
            }
        }
    }
}

struct BudgetRangePicker: View {
    @Binding var range: String
    @Binding var stage: Int
    
    var body: some View {
        Spacer()
        
        VStack{
            Text("Choose a time frame")
                .multilineTextAlignment(.center)
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.bottom, 1)
            Text("The budget will periodically change according to your preference")
                .multilineTextAlignment(.center)
                .font(.headline)
                .foregroundStyle(Color.white.opacity(0.6))
                .frame(width: UIScreen.screenWidth/1.25)
        }
        .padding(10)
        
        VStack {
            Button {
                withAnimation(.easeInOut) {
                    range = "week"
                }
            } label: {
                HStack{
                    Text("Week")
                        .font(.title3)
                        .fontWeight(.semibold)
                    Spacer()
                    if range == "week" {
                        Image(systemName: "checkmark")
                    }
                }
                .foregroundColor(.white)
                .padding(6)
                .background(range == "week" ? Color("lightBackColor"):Color("darkBackColor")).cornerRadius(5)
            }
            
            Button {
                withAnimation(.easeInOut) {
                    range = "month"
                }
            } label: {
                HStack{
                    Text("Month")
                        .font(.title3)
                        .fontWeight(.semibold)
                    Spacer()
                    if range == "month" {
                        Image(systemName: "checkmark")
                    }
                }
                .foregroundColor(.white)
                .padding(6)
                .background(range == "month" ? Color("lightBackColor"):Color("darkBackColor")).cornerRadius(5)
            }
        }
        .frame(width: UIScreen.screenWidth/1.35)
        .padding(6)
        .background(Color("darkBackColor").cornerRadius(10))
        .padding(.top, 50)
        
        Spacer()
        Spacer()
        Spacer()
        
        Button {
            withAnimation(.bouncy) {
                stage = 2
            }
        } label: {
            Text("Continue")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(.black)
                .padding()
        }
        .frame(width: UIScreen.screenWidth/1.1)
        .background(Color.white.cornerRadius(15))
    }
}

struct TargetBudgetView: View {
    @AppStorage("overallBudget") var overallBudget: Double?
    
    @Binding var range: String
    @Binding var stage: Int
    
    @State var counter = 0
    @State var amountString = "0"
    
    var body: some View {
        VStack(alignment: .center) {
            //Header and subheader
            VStack{
                Text("Set up budget amount")
                    .multilineTextAlignment(.center)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.bottom, 1)
                Text("Try your best to stay under the limit and feel free to change it.")
                    .multilineTextAlignment(.center)
                    .font(.headline)
                    .foregroundStyle(Color.white.opacity(0.6))
                    .frame(width: UIScreen.screenWidth/1.4)
            }
            .padding(10)
            
            //Erase button
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
            
            //Amount string
            HStack{
                Text("€")
                    .font(.system(size: 20))
                Text(amountString)
                    .font(.system(size: 40))
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity, alignment: .center)
            
            //Per day
            let amount = Double(amountString) ?? 0
            let devider: Double = range == "week" ? 7:30
            Text("∼€\(amount/devider, specifier: "%.2f") /day")
                .fontWeight(.semibold)
                .foregroundColor(.white.opacity(0.75))
                .padding(10)
                .background(Color("darkBackColor").cornerRadius(100))
        }
        
        Spacer()
        
        BudgetGridView(amountString: $amountString, counter: $counter)
    }
    
    func isDisabled() -> Bool{
        return amountString != "0"
    }
}

struct BudgetGridView: View {
    @Environment(\.dismiss) var dismiss
    
    @AppStorage("overallBudget") var overallBudget: Double?
    
    var grid = [["1", "2", "3"], ["4", "5", "6"], ["7", "8", "9"], [".", "0", "checkmark.square.fill"]]
    @Binding var amountString: String
    @Binding var counter: Int
    @State var isPressed = false
    
    var body: some View {
        ForEach(grid, id: \.self) { row in
            HStack(alignment: .center) {
                ForEach(row, id: \.self) { cell in
                    Button {
                        if cell.count > 1 {
                            if checkSubmit() {
                                let amount = Double(amountString) ?? 0.01
                                overallBudget = amount
                                dismiss()
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
                }
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    func checkSubmit() -> Bool{
        if amountString != "0" && amountString != "0." && amountString != "0.0" && amountString != "0.00" {
            return true
        }
        return false
    }
}

