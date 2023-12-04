//
//  ContentView.swift
//  MyPersonalBudgetApp
//
//  Created by Абубакир on 29.11.2023.
//

import SwiftUI
import SwiftData

struct MainView: View {
    
    @State var selectedTab = 0
    @State var previousTab = 0
    @State private var showFullScreen = false
    
    var body: some View {
        NavigationView {
            VStack {
                // Content for the selected tab
                switch selectedTab {
                case 0:
                    NetView()
                case 1:
                    InsightsView()
                case 2:
                    DarkScreenView()
                        .onAppear(){
                            showFullScreen.toggle()
                        }
                case 3:
                    BudgetView()
                case 4:
                    CategoriesView()
                default:
                    EmptyView()
                }
                
                Spacer()
                
                HStack {
                    TabButton(systemImage: "creditcard.fill", tab: 0, selectedTab: $selectedTab)
                    Spacer()
                    TabButton(systemImage: "chart.bar.xaxis", tab: 1, selectedTab: $selectedTab)
                    Spacer()
                    TabButton(systemImage: "plus", tab: 2, selectedTab: $selectedTab)
                    Spacer()
                    TabButton(systemImage: "chart.pie.fill", tab: 3, selectedTab: $selectedTab)
                    Spacer()
                    TabButton(systemImage: "square.grid.2x2.fill", tab: 4, selectedTab: $selectedTab)
                }
                .padding()
                .padding(.horizontal)
            }
            .navigationBarHidden(true)
        }
        .fullScreenCover(isPresented: $showFullScreen){
            AddTransactionView(selectedTabView: $selectedTab)
        }
        .preferredColorScheme(.dark)
    }
}

struct TabButton: View {
    let systemImage: String
    let tab: Int
    @Binding var selectedTab: Int
    
    var body: some View {
        if tab != 2 {
            Button(action: {
                selectedTab = tab
            }) {
                Image(systemName: systemImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: tab == 4 ? 25:28, height: tab == 4 ? 25:28)
                    .foregroundColor(selectedTab == tab ? .white:.gray)
            }
        } else {
            ZStack{
                RoundedRectangle(cornerRadius: 20.5, style: .continuous).fill(Color.white.opacity(1))
                    .frame(width: 80, height: 53)
                
                Button(action: {
                    selectedTab = tab
                }) {
                    Image(systemName: systemImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                        .foregroundColor(.black)
                        .fontWeight(.semibold)
                }
            }
        }
    }
}

#Preview {
    MainView()
}
