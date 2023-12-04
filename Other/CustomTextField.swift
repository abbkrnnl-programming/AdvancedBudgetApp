//
//  CustomTextField.swift
//  MyPersonalBudgetApp
//
//  Created by Абубакир on 29.11.2023.
//

import Foundation
import SwiftUI

struct CustomTextField: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .font(.headline)
            .padding()
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color(red: 80/255, green: 80/255, blue: 80/255), lineWidth:2)
            )
    }
}
