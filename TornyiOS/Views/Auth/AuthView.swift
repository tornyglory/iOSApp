import SwiftUI
import Foundation

struct AuthView: View {
    @State private var isShowingLogin = true
    @State private var registrationSuccessMessage: String? = nil
    
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
                                successMessage: registrationSuccessMessage,
                                onSwitchToRegister: { 
                                    registrationSuccessMessage = nil
                                    isShowingLogin = false 
                                }
                            )
                        } else {
                            RegisterView(onSwitchToLogin: { message in
                                registrationSuccessMessage = message
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
    }
}

struct LoginView: View {
    @ObservedObject private var apiService = APIService.shared
    @EnvironmentObject private var navigationManager: NavigationManager
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var showingAlert = false
    @State private var alertMessage = ""

    let successMessage: String?
    let onSwitchToRegister: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Sign In")
                .font(TornyFonts.title2)
                .foregroundColor(.tornyTextPrimary)
                .fontWeight(.bold)
            
            // Success message from registration
            if let successMessage = successMessage {
                VStack(spacing: 8) {
                    HStack {
                        Text("🎉")
                            .font(.title2)
                        Text("Registration Successful!")
                            .font(TornyFonts.body)
                            .fontWeight(.semibold)
                            .foregroundColor(.tornyGreen)
                    }
                    Text("You can now log in with your credentials.")
                        .font(TornyFonts.bodySecondary)
                        .foregroundColor(.tornyTextSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.tornyGreen.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.tornyGreen.opacity(0.3), lineWidth: 1)
                        )
                )
            }
            
            VStack(spacing: 16) {
                TextField("Email", text: $email)
                    .textFieldStyle(TornyTextFieldStyle())
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                
                SecureField("Password", text: $password)
                    .textFieldStyle(TornyTextFieldStyle())
                    .textContentType(.password)
            }
            
            Button(action: login) {
                HStack {
                    if isLoading {
                        TornyLoadingView()

                    } else {
                        Text("Sign In")
                    }
                }
            }
            .buttonStyle(TornyPrimaryButton(isLarge: true))
            .frame(maxWidth: .infinity)
            .disabled(isLoading || email.isEmpty || password.isEmpty)

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
    @ObservedObject private var apiService = APIService.shared
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isLoading = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    let onSwitchToLogin: (String) -> Void
    
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
                
                TextField("Email", text: $email)
                    .textFieldStyle(TornyTextFieldStyle())
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                
                SecureField("Password", text: $password)
                    .textFieldStyle(TornyTextFieldStyle())
                    .textContentType(.newPassword)
                
                SecureField("Confirm Password", text: $confirmPassword)
                    .textFieldStyle(TornyTextFieldStyle())
                    .textContentType(.newPassword)
            }
            
            Button(action: register) {
                HStack {
                    if isLoading {
                        TornyLoadingView()

                    } else {
                        Text("Create Account")
                    }
                }
            }
            .buttonStyle(TornyPrimaryButton(isLarge: true))
            .frame(maxWidth: .infinity)
            .disabled(isLoading || !isFormValid)
            
            Button(action: {
                onSwitchToLogin("")
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
    
    private func register() {
        guard password == confirmPassword else {
            alertMessage = "Passwords do not match"
            showingAlert = true
            return
        }
        
        guard password.count >= 6 else {
            alertMessage = "Password must be at least 6 characters"
            showingAlert = true
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
                    // Switch to login with success message
                    onSwitchToLogin(response.message)
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