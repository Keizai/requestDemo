//
//  ContentView.swift
//  RequestDemo
//
//  Created by ZQ on 2025/4/7.
//

import SwiftUI

struct ContentView: View {
    @State private var phoneNumber = ""
    @State private var isLoading = false
    @State private var resultMessage = ""
    @State private var showAlert = false
    
    private let verificationService = VerificationCodeService()
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Verification Code Demo")
                .font(.title)
                .padding()
            
            TextField("Enter phone number (55 + 8 digits)", text: $phoneNumber)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .textContentType(.telephoneNumber)
                .keyboardType(.numberPad)
                .padding(.horizontal)
            
            Button(action: sendVerificationCode) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text("Send Verification Code")
                        .foregroundColor(.white)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .cornerRadius(10)
            .padding(.horizontal)
            .disabled(isLoading || phoneNumber.count != 10)
            
            if !resultMessage.isEmpty {
                Text(resultMessage)
                    .foregroundColor(.red)
                    .padding()
            }
        }
        .alert("Error", isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(resultMessage)
        }
    }
    
    private func sendVerificationCode() {
        guard phoneNumber.count == 10 else {
            resultMessage = "Please enter a valid phone number (55 + 8 digits)"
            showAlert = true
            return
        }
        
        isLoading = true
        resultMessage = ""
        
        Task {
            do {
                let response = try await verificationService.sendVerificationCode(mobile: phoneNumber)
                await MainActor.run {
                    resultMessage = "Success: \(response)"
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    resultMessage = "Error: \(error.localizedDescription)"
                    isLoading = false
                    showAlert = true
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
