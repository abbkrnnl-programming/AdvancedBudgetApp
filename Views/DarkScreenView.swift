//
//  DarkScreenView.swift
//  MyPersonalBudgetApp
//
//  Created by Абубакир on 29.11.2023.
//

import SwiftUI

struct DarkScreenView: View {
    var body: some View {
        ZStack{
            Color.black
                .ignoresSafeArea(.all)
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    DarkScreenView()
}
