//
//  BudgetView.swift
//  MyPersonalBudgetApp
//
//  Created by Абубакир on 29.11.2023.
//

import SwiftUI
import SwiftData
import CrookedText

struct BudgetView: View {
    @Environment(\.modelContext) var context
    @Query(sort: \Transaction.date, order: .reverse) var transactions: [Transaction]
    
    @AppStorage("overallBudget") var overallBudget: Double?
    
    @State var range = "week"
    @State var showSheet = false
    @State var totalSpentWeek = 0.0
    @State var totalSpentMonth = 0.0
    
    var body: some View {
        NavigationView {
            VStack{
                VStack {
                    let budget = overallBudget ?? 0.01
                    let leftWeek: Double = abs(budget-totalSpentWeek)
                    let leftMonth: Double = abs(budget-totalSpentMonth)
                    let percentageSpent: Double = 100.0*totalSpentWeek/budget
                    
                    Text("OVERALL SPENT: " + "\(percentageSpent)%")
                        .foregroundStyle(percentageSpent <= 100.0 ? .white.opacity(0.65):.red.opacity(0.8))
                        .font(.headline)
                        .frame(width: 300, height: 20)
                        .padding(.top, 20)
                    
                    ZStack(alignment: .bottom) {
                        DonutSemicircle(percent: 1, cornerRadius: 8, width: 35)
                            .foregroundStyle(Color("lightBackColor"))
                            .frame(width: UIScreen.screenWidth-90, height: UIScreen.screenWidth/2-45)
                        
                        if range == "week" && budget >= totalSpentWeek {
                            DonutSemicircle(percent: leftWeek / (overallBudget ?? 0.01), cornerRadius: 8, width: 35)
                                .frame(width: UIScreen.screenWidth-90, height: UIScreen.screenWidth/2-45)
                        } else if range == "month" {
                            if budget >= totalSpentMonth {
                                DonutSemicircle(percent: leftMonth / (overallBudget ?? 0.01), cornerRadius: 8, width: 35)
                                    .frame(width: UIScreen.screenWidth-90, height: UIScreen.screenWidth/2-45)
                            }
                        }
                        
                        VStack {
                            HStack(alignment: .center, spacing: 3){
                                Text("€")
                                    .font(.title)
                                    .foregroundStyle(.white.opacity(0.7))
                                    .fontWeight(.semibold)
                                Text(range == "week" ? "\(leftWeek, specifier: "%.2f")":"\(leftMonth, specifier: "%.2f")")
                                    .font(.system(size: 32))
                                    .fontWeight(.semibold)
                            }
                            if range == "week" {
                                Text(overallBudget ?? 0.01 >= totalSpentWeek ? "left this week":"over this week")
                            } else {
                                Text(overallBudget ?? 0.01 >= totalSpentMonth ? "left this month":"over this month")
                            }
                        }
                    }
                    
                    VStack {
                        HStack {
                            //Text(range == "week" ? "\(leftWeek, specifier: "%.2f")":"\(leftMonth, specifier: "%.2f")")
                            Text("0,00")
                            Spacer()
                            Text("\(overallBudget ?? 0.01, specifier: "%.2f")")
                        }
                        .frame(width: UIScreen.screenWidth-90)
                        .font(.footnote)
                        .fontWeight(.semibold)
                    }
                }
                .padding(.bottom, 25)
                .padding(.horizontal, 20)
                .background(Color("darkBackColor").cornerRadius(8))
                .padding(.top, 30)
                .onAppear {
                    BudgetCalc()
                }
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Text("Budget")
                            .font(.title)
                            .fontWeight(.semibold)
                            .padding()
                    }
                    
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            showSheet.toggle()
                        } label: {
                            HStack(spacing: 2){
                                if overallBudget != nil {
                                    Image(systemName: "pencil")
                                        .font(.caption)
                                }
                                Text(overallBudget == nil ? "+ new":"edit")
                                    .font(.headline)
                            }
                            .foregroundStyle(.white)
                            .padding(4)
                            .padding(.horizontal, 4)
                            .background(Color("lightBackColor").cornerRadius(6))
                        }
                        .padding()
                    }
                }
                .sheet(isPresented: $showSheet) {
                    AddBudgetView(range: $range)
                }
                
                ScrollView{
                    
                }
            }
            .overlay{
                if overallBudget == nil {
                    UnavailableContentView()
                    .offset(y: 0)
                }
            }
        }
    }
    
    func BudgetCalc() {
        let calendar = Calendar.current
        for transaction in transactions {
            if !transaction.income {
                if calendar.component(.weekOfYear, from: Date()) == calendar.component(.weekOfYear, from: transaction.date){
                    totalSpentWeek += transaction.amount
                    if calendar.component(.month, from: Date()) == calendar.component(.month, from: transaction.date) {
                        totalSpentMonth += transaction.amount
                    }
                }
                if calendar.component(.month, from: Date()) == calendar.component(.month, from: transaction.date) {
                    totalSpentMonth += transaction.amount
                }
            }
        }
    }
}

struct DonutSemicircle: Shape {
    var percent: Double

    var animatableData: Double {
        get { percent }
        set { percent = newValue }
    }

    var cornerRadius: CGFloat
    var width: CGFloat

    func path(in rect: CGRect) -> Path {
        let radius = rect.width / 2
        let center = CGPoint(x: rect.midX, y: rect.maxY)
        let cornerAngle = asin(cornerRadius / (radius - cornerRadius))
        let endAngle = Angle(degrees: 180 + (180 * percent)) - Angle(radians: cornerAngle)
        let weirdLength = sqrt(((radius - cornerRadius) * (radius - cornerRadius)) - (cornerRadius * cornerRadius))
        let weirderLength = radius - weirdLength
        let innerRadius = radius - width
        let stupidAngle = acos(((innerRadius + cornerRadius) * (innerRadius + cornerRadius) + (innerRadius + weirderLength) * (innerRadius + weirderLength) - cornerRadius * cornerRadius) / (2 * (innerRadius + cornerRadius) * (innerRadius + weirderLength)))
        let dumbassAngle = asin(cornerRadius / (innerRadius + cornerRadius))

        var path = Path()
        path.move(to: CGPoint(x: radius - weirdLength, y: rect.maxY))
//        path.move(to:CGPoint(x: rect.width * 0.3, y: rect.maxY))

        let firstControlPoint = CGPoint(x: radius - radius * cos(cornerAngle), y: rect.maxY - radius * sin(cornerAngle))

        path.addQuadCurve(to: firstControlPoint, control: CGPoint(x: 0, y: rect.maxY))

        if endAngle > Angle(radians: CGFloat.pi + cornerAngle) {
            path.addArc(center: center, radius: radius, startAngle: Angle(radians: CGFloat.pi + cornerAngle), endAngle: endAngle, clockwise: false)
        }

        var secondControlPoint: CGPoint
        var secondControlPointTo: CGPoint
        var thirdControlPointFrom: CGPoint
        var thirdControlPoint: CGPoint
        var thirdControlPointTo: CGPoint

        if percent > 0.5 {
            secondControlPoint = CGPoint(x: radius + radius * cos(CGFloat(180 * (1 - percent)).toRadians()), y: radius - radius * sin(CGFloat(180 * (1 - percent)).toRadians()))
            secondControlPointTo = CGPoint(x: radius + weirdLength * cos(CGFloat(180 * (1 - percent)).toRadians()), y: radius - weirdLength * sin(CGFloat(180 * (1 - percent)).toRadians()))
            thirdControlPointFrom = CGPoint(x: radius + (innerRadius + weirderLength) * cos(CGFloat(180 * (1 - percent)).toRadians()), y: radius - (innerRadius + weirderLength) * sin(CGFloat(180 * (1 - percent)).toRadians()))
            thirdControlPoint = CGPoint(x: radius + innerRadius * cos(CGFloat(180 * (1 - percent)).toRadians()), y: radius - innerRadius * sin(CGFloat(180 * (1 - percent)).toRadians()))
            thirdControlPointTo = CGPoint(x: radius + innerRadius * cos(stupidAngle + CGFloat(180 * (1 - percent)).toRadians()), y: radius - innerRadius * sin(stupidAngle + CGFloat(180 * (1 - percent)).toRadians()))

        } else if percent < 0.5 {
            secondControlPoint = CGPoint(x: radius - radius * cos(CGFloat(180 * percent).toRadians()), y: radius - radius * sin(CGFloat(180 * percent).toRadians()))
            secondControlPointTo = CGPoint(x: radius - weirdLength * cos(CGFloat(180 * percent).toRadians()), y: radius - weirdLength * sin(CGFloat(180 * percent).toRadians()))
            thirdControlPointFrom = CGPoint(x: radius - (innerRadius + weirderLength) * cos(CGFloat(180 * percent).toRadians()), y: radius - (innerRadius + weirderLength) * sin(CGFloat(180 * percent).toRadians()))
            thirdControlPoint = CGPoint(x: radius - innerRadius * cos(CGFloat(180 * percent).toRadians()), y: radius - innerRadius * sin(CGFloat(180 * percent).toRadians()))
            thirdControlPointTo = CGPoint(x: radius - innerRadius * cos(-stupidAngle + CGFloat(180 * percent).toRadians()), y: radius - innerRadius * sin(-stupidAngle + CGFloat(180 * percent).toRadians()))
        } else {
            secondControlPoint = CGPoint(x: rect.midX, y: rect.minY)
            secondControlPointTo = CGPoint(x: rect.midX, y: radius - weirdLength)
            thirdControlPointFrom = CGPoint(x: rect.midX, y: radius - (innerRadius + weirderLength))
            thirdControlPoint = CGPoint(x: rect.midX, y: width)
            thirdControlPointTo = CGPoint(x: radius - innerRadius * cos(CGFloat.pi / 2 - stupidAngle), y: radius - innerRadius * sin(CGFloat.pi / 2 - stupidAngle))
        }

        path.addQuadCurve(to: secondControlPointTo, control: secondControlPoint)

        path.addLine(to: thirdControlPointFrom)
        path.addQuadCurve(to: thirdControlPointTo, control: thirdControlPoint)

        if (endAngle - Angle(radians: stupidAngle)) > Angle(radians: CGFloat.pi + dumbassAngle) {
            path.addArc(center: center, radius: innerRadius, startAngle: endAngle - Angle(radians: stupidAngle), endAngle: Angle(radians: CGFloat.pi + dumbassAngle), clockwise: true)
        }

        let fourthControlPoint = CGPoint(x: width, y: rect.maxY)
        let fourthControlPointTo = CGPoint(x: width - weirderLength, y: rect.maxY)

        path.addQuadCurve(to: fourthControlPointTo, control: fourthControlPoint)

        path.closeSubpath()
        return path
    }
}



//struct DonutSemicircle: Shape {
//    var percent: Double
//    
//    var animatableData: Double {
//        get { percent }
//        set { percent = newValue }
//    }
//    
//    func path(in rect: CGRect) -> Path {
//        let radius = rect.width / 2
//        let center = CGPoint(x: rect.midX, y: rect.midY)
//        let startAngle = Angle(degrees: 0+180)
//        let endAngle = Angle(degrees: 180 * percent+180)
//        
//        var path = Path()
//        
//        // Outer arc
//        path.addArc(
//            center: center,
//            radius: radius,
//            startAngle: startAngle,
//            endAngle: endAngle,
//            clockwise: false
//        )
//        
//        // Inner arc
//        let innerRadius = radius - 30 // Adjust the inner radius as needed
//        path.addArc(
//            center: center,
//            radius: innerRadius,
//            startAngle: endAngle,
//            endAngle: startAngle,
//            clockwise: true
//        )
//        
//        // Close the path
//        path.closeSubpath()
//        
//        return path
//    }
//}







#Preview {
    BudgetView()
}
