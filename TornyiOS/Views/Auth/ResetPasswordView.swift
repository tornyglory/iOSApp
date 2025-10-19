import SwiftUI

struct ResetPasswordView: View {
    let token: String
    @StateObject private var passwordResetService = PasswordResetService()
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var isLoading = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var resetSuccess = false
    @State private var tokenValid = false
    @State private var userEmail = ""
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ZStack {
                TornyBackgroundView()

                ScrollView {
                    VStack(spacing: 32) {
                        // Header
                        VStack(spacing: 16) {
                            Image(systemName: "lock.shield.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.tornyBlue)

                            Text("Create New Password")
                                .font(TornyFonts.title1)
                                .fontWeight(.bold)
                                .foregroundColor(.tornyTextPrimary)

                            if !userEmail.isEmpty {
                                Text("Creating new password for \(userEmail)")
                                    .font(TornyFonts.body)
                                    .foregroundColor(.tornyTextSecondary)
                                    .multilineTextAlignment(.center)
                            } else {
                                Text("Enter your new password below.")
                                    .font(TornyFonts.body)
                                    .foregroundColor(.tornyTextSecondary)
                                    .multilineTextAlignment(.center)
                            }
                        }
                        .padding(.top, 40)

                        if resetSuccess {
                            // Success state
                            VStack(spacing: 24) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 60))
                                    .foregroundColor(.tornyGreen)

                                VStack(spacing: 12) {
                                    Text("Password Reset Successfully!")
                                        .font(TornyFonts.title2)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.tornyTextPrimary)

                                    Text("Your password has been successfully reset. You can now log in with your new password.")
                                        .font(TornyFonts.body)
                                        .foregroundColor(.tornyTextSecondary)
                                        .multilineTextAlignment(.center)
                                }

                                Button("Go to Login") {
                                    dismiss()
                                }
                                .buttonStyle(TornyPrimaryButton(isLarge: true))
                                .padding(.top, 16)
                            }
                        } else if tokenValid {
                            // Form state
                            TornyCard {
                                VStack(alignment: .leading, spacing: 24) {
                                    Text("New Password")
                                        .font(TornyFonts.title3)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.tornyTextPrimary)

                                    VStack(alignment: .leading, spacing: 16) {
                                        VStack(alignment: .leading, spacing: 8) {
                                            Text("Password")
                                                .font(TornyFonts.body)
                                                .fontWeight(.medium)
                                                .foregroundColor(.tornyTextPrimary)

                                            SecureField("Enter new password", text: $newPassword)
                                                .textFieldStyle(TornyTextFieldStyle())
                                                .disabled(isLoading)
                                        }

                                        VStack(alignment: .leading, spacing: 8) {
                                            Text("Confirm Password")
                                                .font(TornyFonts.body)
                                                .fontWeight(.medium)
                                                .foregroundColor(.tornyTextPrimary)

                                            SecureField("Confirm new password", text: $confirmPassword)
                                                .textFieldStyle(TornyTextFieldStyle())
                                                .disabled(isLoading)
                                        }

                                        // Password Requirements
                                        VStack(alignment: .leading, spacing: 8) {
                                            Text("Password Requirements:")
                                                .font(TornyFonts.bodySecondary)
                                                .fontWeight(.medium)
                                                .foregroundColor(.tornyTextSecondary)

                                            VStack(alignment: .leading, spacing: 4) {
                                                HStack(spacing: 8) {
                                                    Image(systemName: newPassword.count >= 8 ? "checkmark.circle.fill" : "circle")
                                                        .foregroundColor(newPassword.count >= 8 ? .tornyGreen : .gray)
                                                        .font(.caption)

                                                    Text("At least 8 characters")
                                                        .font(TornyFonts.caption)
                                                        .foregroundColor(newPassword.count >= 8 ? .tornyGreen : .gray)
                                                }

                                                HStack(spacing: 8) {
                                                    Image(systemName: passwordsMatch ? "checkmark.circle.fill" : "circle")
                                                        .foregroundColor(passwordsMatch ? .tornyGreen : .gray)
                                                        .font(.caption)

                                                    Text("Passwords match")
                                                        .font(TornyFonts.caption)
                                                        .foregroundColor(passwordsMatch ? .tornyGreen : .gray)
                                                }
                                            }
                                        }
                                    }

                                    Button(action: resetPassword) {
                                        HStack {
                                            if isLoading {
                                                TornyLoadingView()
                                                Text("Resetting...")
                                            } else {
                                                Image(systemName: "lock.rotation")
                                                Text("Reset Password")
                                            }
                                        }
                                    }
                                    .buttonStyle(TornyPrimaryButton(isLarge: true))
                                    .disabled(!isFormValid || isLoading)
                                }
                                .padding()
                            }
                        } else {
                            // Loading or error state
                            VStack(spacing: 24) {
                                if isLoading {
                                    TornyLoadingView()
                                    Text("Validating reset link...")
                                        .font(TornyFonts.body)
                                        .foregroundColor(.tornyTextSecondary)
                                } else {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .font(.system(size: 60))
                                        .foregroundColor(.orange)

                                    VStack(spacing: 12) {
                                        Text("Invalid Reset Link")
                                            .font(TornyFonts.title2)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.tornyTextPrimary)

                                        Text("This password reset link is invalid or has expired. Please request a new one.")
                                            .font(TornyFonts.body)
                                            .foregroundColor(.tornyTextSecondary)
                                            .multilineTextAlignment(.center)
                                    }

                                    Button("Request New Reset Link") {
                                        dismiss()
                                    }
                                    .buttonStyle(TornyPrimaryButton(isLarge: true))
                                    .padding(.top, 16)
                                }
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
            if resetSuccess {
                Button("Go to Login") {
                    dismiss()
                }
            } else {
                Button("OK") { }
            }
        } message: {
            Text(alertMessage)
        }
        .onAppear {
            validateToken()
        }
    }

    private var passwordsMatch: Bool {
        !newPassword.isEmpty && !confirmPassword.isEmpty && newPassword == confirmPassword
    }

    private var isFormValid: Bool {
        newPassword.count >= 8 && passwordsMatch
    }

    private func validateToken() {
        isLoading = true

        Task {
            do {
                let response = try await passwordResetService.validateResetToken(token)

                await MainActor.run {
                    isLoading = false
                    tokenValid = true
                    userEmail = response.data?.email ?? ""
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    tokenValid = false
                    alertMessage = error.localizedDescription
                }
            }
        }
    }

    private func resetPassword() {
        guard isFormValid else { return }

        isLoading = true

        Task {
            do {
                let success = try await passwordResetService.resetPassword(token: token, newPassword: newPassword)

                await MainActor.run {
                    isLoading = false
                    if success {
                        resetSuccess = true
                        alertMessage = "Password has been successfully reset. You can now log in with your new password."
                        showingAlert = true
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

struct ResetPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ResetPasswordView(token: "sample-token")
    }
}