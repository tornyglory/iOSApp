import SwiftUI
import Foundation

struct AuthView: View {
    @State private var isShowingLogin = true
    @EnvironmentObject private var navigationManager: NavigationManager

    var body: some View {
        ZStack {
            TornyBackgroundView()

            ScrollView {
                VStack(spacing: 20) {
                    Spacer(minLength: 40)

                    // Logo and Branding - Larger and closer to form
                    VStack(spacing: 20) {
                        TornyLogoView(size: CGSize(width: 200, height: 100))
                    }

                    // Auth Forms
                    TornyCard {
                        if isShowingLogin {
                            LoginView(
                                onSwitchToRegister: {
                                    isShowingLogin = false
                                }
                            )
                        } else {
                            RegisterView(onSwitchToLogin: {
                                isShowingLogin = true
                            })
                        }
                    }
                    .padding(.horizontal, 20)

                    Spacer(minLength: 40)
                }
            }
        }
        .ignoresSafeArea()
        .sheet(isPresented: $navigationManager.showingForgotPassword) {
            ForgotPasswordView()
        }
        .sheet(isPresented: $navigationManager.showingPasswordReset) {
            if let token = navigationManager.passwordResetToken {
                ResetPasswordView(token: token)
            }
        }
    }
}

struct LoginView: View {
    private var apiService: APIService { APIService.shared }
    @EnvironmentObject private var navigationManager: NavigationManager
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var showValidationErrors = false

    let onSwitchToRegister: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Sign In")
                .font(TornyFonts.title2)
                .foregroundColor(.tornyTextPrimary)
                .fontWeight(.bold)

            VStack(spacing: 16) {
                TextField("Email", text: $email)
                    .textFieldStyle(TornyTextFieldStyle())
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .onChange(of: email) { _ in
                        if showValidationErrors { showValidationErrors = false }
                    }

                SecureField("Password", text: $password)
                    .textFieldStyle(TornyTextFieldStyle())
                    .textContentType(.password)
                    .onChange(of: password) { _ in
                        if showValidationErrors { showValidationErrors = false }
                    }
            }

            // Validation error messages
            if showValidationErrors {
                VStack(alignment: .leading, spacing: 8) {
                    if email.isEmpty {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.circle.fill")
                                .foregroundColor(.red)
                            Text("Email is required")
                                .font(TornyFonts.bodySecondary)
                                .foregroundColor(.red)
                        }
                    }
                    if password.isEmpty {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.circle.fill")
                                .foregroundColor(.red)
                            Text("Password is required")
                                .font(TornyFonts.bodySecondary)
                                .foregroundColor(.red)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 4)
            }

            Button(action: login) {
                HStack {
                    if isLoading {
                        TornyButtonSpinner()
                    } else {
                        Text("Sign In")
                    }
                }
            }
            .buttonStyle(TornyPrimaryButton(isLarge: true))
            .frame(maxWidth: .infinity)
            .disabled(isLoading)

            // Forgot Password Link
            Button("Forgot Password?") {
                navigationManager.showForgotPassword()
            }
            .font(TornyFonts.bodySecondary)
            .foregroundColor(.tornyBlue)
            .disabled(isLoading)

            Button(action: {
                onSwitchToRegister()
            }) {
                HStack(spacing: 4) {
                    Text("Don't have an account?")
                        .foregroundColor(.black)
                    Text("Sign Up")
                        .foregroundColor(.tornyBlue)
                }
            }
            .font(TornyFonts.body)
        }
        .alert("Error", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func login() {
        // Validate fields first
        guard !email.isEmpty && !password.isEmpty else {
            showValidationErrors = true
            return
        }

        isLoading = true

        let request = LoginRequest(email: email, password: password)

        Task {
            do {
                let response = try await apiService.login(request)
                await MainActor.run {
                    print("✅ Login successful!")
                    print("User: \(response.user.email)")
                    isLoading = false
                    // Login successful - the app should automatically navigate to main screen
                    // because apiService.isAuthenticated is now true
                }
            } catch {
                await MainActor.run {
                    print("❌ Login failed: \(error)")
                    alertMessage = error.localizedDescription
                    showingAlert = true
                    isLoading = false
                }
            }
        }
    }
}

struct RegisterView: View {
    private var apiService: APIService { APIService.shared }
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isLoading = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var showValidationErrors = false

    let onSwitchToLogin: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Create Account")
                .font(TornyFonts.title2)
                .foregroundColor(.tornyTextPrimary)
                .fontWeight(.bold)
            
            VStack(spacing: 16) {
                TextField("Full Name", text: $name)
                    .textFieldStyle(TornyTextFieldStyle())
                    .textContentType(.name)
                    .onChange(of: name) { _ in
                        if showValidationErrors { showValidationErrors = false }
                    }

                TextField("Email", text: $email)
                    .textFieldStyle(TornyTextFieldStyle())
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .onChange(of: email) { _ in
                        if showValidationErrors { showValidationErrors = false }
                    }

                SecureField("Password", text: $password)
                    .textFieldStyle(TornyTextFieldStyle())
                    .textContentType(.newPassword)
                    .onChange(of: password) { _ in
                        if showValidationErrors { showValidationErrors = false }
                    }

                SecureField("Confirm Password", text: $confirmPassword)
                    .textFieldStyle(TornyTextFieldStyle())
                    .textContentType(.newPassword)
                    .onChange(of: confirmPassword) { _ in
                        if showValidationErrors { showValidationErrors = false }
                    }
            }

            // Validation error messages
            if showValidationErrors {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(validationErrors, id: \.self) { error in
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.circle.fill")
                                .foregroundColor(.red)
                            Text(error)
                                .font(TornyFonts.bodySecondary)
                                .foregroundColor(.red)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 4)
            }

            Button(action: register) {
                HStack {
                    if isLoading {
                        TornyButtonSpinner()
                    } else {
                        Text("Create Account")
                    }
                }
            }
            .buttonStyle(TornyPrimaryButton(isLarge: true))
            .frame(maxWidth: .infinity)
            .disabled(isLoading)
            
            Button(action: {
                onSwitchToLogin()
            }) {
                HStack(spacing: 4) {
                    Text("Already have an account?")
                        .foregroundColor(.black)
                    Text("Sign In")
                        .foregroundColor(.tornyBlue)
                }
            }
            .font(TornyFonts.body)
        }
        .alert("Error", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private var isFormValid: Bool {
        !name.isEmpty &&
        !email.isEmpty &&
        !password.isEmpty &&
        !confirmPassword.isEmpty &&
        password == confirmPassword &&
        password.count >= 6
    }

    private var validationErrors: [String] {
        var errors: [String] = []

        if name.isEmpty {
            errors.append("Full name is required")
        }
        if email.isEmpty {
            errors.append("Email is required")
        }
        if password.isEmpty {
            errors.append("Password is required")
        } else if password.count < 6 {
            errors.append("Password must be at least 6 characters")
        }
        if confirmPassword.isEmpty {
            errors.append("Please confirm your password")
        } else if !password.isEmpty && password != confirmPassword {
            errors.append("Passwords do not match")
        }

        return errors
    }
    
    private func register() {
        // Validate form first
        guard isFormValid else {
            showValidationErrors = true
            return
        }

        isLoading = true
        
        let request = RegisterRequest(
            email: email,
            name: name,
            password: password,
            phone: nil,
            address: nil,
            description: nil,
            avatarUrl: nil,
            club: nil
        )
        
        Task {
            do {
                let response = try await apiService.register(request)
                await MainActor.run {
                    print("✅ Registration successful: \(response.message)")
                    isLoading = false
                    // Switch to login
                    onSwitchToLogin()
                }
            } catch {
                await MainActor.run {
                    print("❌ Registration failed: \(error)")
                    alertMessage = error.localizedDescription
                    showingAlert = true
                    isLoading = false
                }
            }
        }
    }
}

struct AuthView_Previews: PreviewProvider {
    static var previews: some View {
        AuthView()
    }
}