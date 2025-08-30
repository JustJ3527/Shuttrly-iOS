//
//  DigitField.swift
//  ShuttrlyApp
//
//  Created by Jules Antoine on 28/08/2025.
//

import SwiftUI

// MARK: - Digit Field
// Shared component for 2FA code input fields

struct DigitField: View {
    
    let numberOfFields: Int
    @Binding var code: String
    
    @State private var enterValue: [String]
    @FocusState private var fieldFocus: Int?
    
    init(numberOfFields: Int, code: Binding<String>) {
        self.numberOfFields = numberOfFields
        self._code = code
        self.enterValue = Array(repeating: "", count: numberOfFields)
    }
    
    var body: some View {
        HStack(spacing: 12) {
            ForEach(0..<numberOfFields, id: \.self) { index in
                TextField("", text: $enterValue[index])
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.center)
                    .font(.title2)
                    .fontWeight(.bold)
                    .frame(width: 50, height: 60)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(fieldFocus == index ? Color("primaryDefaultColor") : Color.gray.opacity(0.3), lineWidth: fieldFocus == index ? 2 : 1)
                    )
                    .focused($fieldFocus, equals: index)
                    .onSubmit {
                        // Handle backspace on empty field - delete previous field content
                        if enterValue[index].isEmpty && index > 0 {
                            enterValue[index - 1] = ""
                            DispatchQueue.main.async {
                                fieldFocus = index - 1
                            }
                            updateCodeBinding()
                        }
                    }
                    .onChange(of: enterValue[index]) { oldValue, newValue in
                        // Only allow single digits
                        if newValue.count > 1 {
                            enterValue[index] = String(newValue.prefix(1))
                        }
                        
                        // Only allow numbers
                        if !newValue.isEmpty && !newValue.first!.isNumber {
                            enterValue[index] = ""
                            return
                        }
                        
                        // Handle deletion (backspace)
                        if newValue.isEmpty && !oldValue.isEmpty {
                            // Move focus to previous field when deleting
                            if index > 0 {
                                DispatchQueue.main.async {
                                    fieldFocus = index - 1
                                }
                            }
                        }
                        
                        // Update the main code binding
                        updateCodeBinding()
                        
                        // Auto-focus next field if available (only when adding a digit)
                        if index < numberOfFields - 1 && !newValue.isEmpty && newValue.count > oldValue.count {
                            DispatchQueue.main.async {
                                fieldFocus = index + 1
                            }
                        }
                    }
            }
        }
        .onAppear {
            // Focus first field when view appears
            fieldFocus = 0
        }
    }
    
    private func updateCodeBinding() {
        // Combine all values into the code string
        code = enterValue.joined()
    }
}

// MARK: - Preview
#Preview {
    DigitField(numberOfFields: 6, code: .constant(""))
        .padding()
        .background(Color("backgroundDefaultColor"))
}
