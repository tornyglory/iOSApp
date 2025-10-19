import SwiftUI

struct ForgotPasswordView: View {
    @StateObject private var passwordResetService = PasswordResetService()
    @State private var email = ""
    @State private var isLoading = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var resetRequestSent = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ZStack {
                TornyBackgroundView()

                ScrollView {
                    VStack(spacing: 32) {
                        // Header - only show when not sent
                        if !resetRequestSent {
                            VStack(spacing: 16) {
                                Image(systemName: "envelope.circle.fill")
                                    .font(.system(size: 60))
                                    .foregroundColor(.tornyBlue)

                                Text("Reset Password")
                                    .font(TornyFonts.title1)
                                    .fontWeight(.bold)
                                    .foregroundColor(.tornyTextPrimary)

                                Text("Enter your email address and we'll send you a link to reset your password.")
                                    .font(TornyFonts.body)
                                    .foregroundColor(.tornyTextSecondary)
                                    .multilineTextAlignment(.center)
                            }
                            .padding(.top, 40)
                        }

                        if resetRequestSent {
                            // Success state
                            VStack(spacing: 24) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 60))
                                    .foregroundColor(.tornyGreen)

                                VStack(spacing: 12) {
                                    Text("Email Sent!")
                                        .font(TornyFonts.title2)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.tornyTextPrimary)

                                    Text("If an account with this email exists, we've sent a password reset link to \(email)")
                                        .font(TornyFonts.body)
                                        .foregroundColor(.tornyTextSecondary)
                                        .multilineTextAlignment(.center)

                                    Text("Check your email and follow the instructions to reset your password.")
                                        .font(TornyFonts.bodySecondary)
                                        .foregroundColor(.tornyTextSecondary)
                                        .multilineTextAlignment(.center)
                                        .padding(.top, 8)
                                }

                                Button("Back to Login") {
                                    dismiss()
                                }
                                .buttonStyle(TornyPrimaryButton(isLarge: true))
                                .padding(.top, 16)
                            }
                            .padding(.top, 60)
                        } else {
                            // Form state
                            TornyCard {
                                VStack(alignment: .leading, spacing: 24) {
                                    Text("Email Address")
                                        .font(TornyFonts.title3)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.tornyTextPrimary)

                                    VStack(alignment: .leading, spacing: 8) {
                                        TextField("Enter your email", text: $email)
                                            .textFieldStyle(TornyTextFieldStyle())
                                            .keyboardType(.emailAddress)
                                            .autocapitalization(.none)
                                            .autocorrectionDisabled()
                                            .disabled(isLoading)

                                        if !email.isEmpty && !PasswordResetService.isValidEmail(email) {
                                            Text("Please enter a valid email address")
                                                .font(TornyFonts.caption)
                                                .foregroundColor(.red)
                                        }
                                    }

                                    Button(action: sendResetRequest) {
                                        HStack {
                                            if isLoading {
                                                TornyLoadingView()

                                            } else {
                                                Image(systemName: "envelope.fill")
                                                Text("Send Reset Link")
                                            }
                                        }
                                    }
                                    .buttonStyle(TornyPrimaryButton(isLarge: true))
                                    .disabled(!isFormValid || isLoading)
                                }
                                .padding()
                            }
                        }

                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 20)
                }
            }
            .navigationTitle("Reset Password")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.tornyBlue)
                }
            }
        }
        .alert("Password Reset", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
    }

    private var isFormValid: Bool {
        PasswordResetService.isValidEmail(email)
    }

    private func sendResetRequest() {
        guard isFormValid else { return }

        isLoading = true

        Task {
            do {
                let success = try await passwordResetService.requestPasswordReset(email: email)

                await MainActor.run {
                    isLoading = false
                    if success {
                        resetRequestSent = true
                    }
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    alertMessage = error.localizedDescription
                    showingAlert = true
                }
            }
        }
    }
}

// MARK: - Custom Text Field Style


struct ForgotPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ForgotPasswordView()
    }
}