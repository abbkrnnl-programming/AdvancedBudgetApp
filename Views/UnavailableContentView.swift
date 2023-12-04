//
//  UnavailableContentView.swift
//  MyPersonalBudgetApp
//
//  Created by Абубакир on 02.12.2023.
//

import SwiftUI

struct UnavailableContentView: View {
    var body: some View {
        ZStack(alignment: .center){
            Color.black
                .ignoresSafeArea(.all)
            VStack{
                Text("🙈")
                    .font(.system(size: 48))
                    .padding(.bottom, 7)
                Text("No Budgets Found")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.bottom, 3)
                Text("Add your first budget today!")
                    .font(.headline)
                    .foregroundStyle(.white.opacity(0.4))
            }
            .frame(maxWidth: .infinity)
            .padding(.top, -50)
        }
    }
}

#Preview {
    UnavailableContentView()
}
