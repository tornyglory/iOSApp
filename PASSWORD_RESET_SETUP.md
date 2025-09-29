# Password Reset Setup Guide

## Overview
This guide outlines the setup required to enable password reset functionality in the Torny iOS app, including deep link configuration and testing.

## Files Added

### 1. Password Reset Service
- **Location**: `TornyiOS/Services/Network/PasswordResetService.swift`
- **Purpose**: Handles API calls for password reset functionality
- **Features**:
  - Request password reset
  - Validate reset tokens
  - Reset password with new credentials
  - Comprehensive error handling

### 2. Forgot Password View
- **Location**: `TornyiOS/Views/Auth/ForgotPasswordView.swift`
- **Purpose**: UI for requesting password reset
- **Features**:
  - Email input with validation
  - Loading states
  - Success confirmation
  - Error handling

### 3. Reset Password View
- **Location**: `TornyiOS/Views/Auth/ResetPasswordView.swift`
- **Purpose**: UI for setting new password after clicking reset link
- **Features**:
  - Token validation
  - Password strength requirements
  - Confirmation field matching
  - Success flow to login

### 4. Navigation Manager
- **Location**: `TornyiOS/Services/Utilities/NavigationManager.swift`
- **Purpose**: Handles deep link navigation and app state
- **Features**:
  - Deep link URL parsing
  - Navigation state management
  - Password reset flow coordination

## Required Xcode Configuration

### 1. Add URL Scheme to Info.plist

You need to add the following to your app's `Info.plist` file in Xcode:

1. Open your project in Xcode
2. Select your app target
3. Go to the "Info" tab
4. Add a new entry under "URL Types":

**Method 1: Through Xcode UI**
- Click the "+" button under URL Types
- **Identifier**: `torny.password.reset`
- **URL Schemes**: `torny`
- **Role**: `Editor`

**Method 2: Directly in Info.plist**
Add this XML to your Info.plist:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLName</key>
        <string>torny.password.reset</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>torny</string>
        </array>
    </dict>
</array>
```

### 2. Add New Files to Xcode Project

Make sure to add these new Swift files to your Xcode project:

1. Right-click your project in Xcode navigator
2. Select "Add Files to 'TornyiOS'"
3. Add the following files:
   - `PasswordResetService.swift`
   - `ForgotPasswordView.swift`
   - `ResetPasswordView.swift`
   - `NavigationManager.swift`

## API Endpoints

The password reset functionality uses these API endpoints:

### 1. Request Reset
- **URL**: `POST /api/request-password-reset`
- **Body**: `{"email": "user@example.com"}`
- **Response**: Success message or error

### 2. Validate Token
- **URL**: `GET /api/validate-reset-token?token={token}`
- **Response**: Token validation with user email

### 3. Reset Password
- **URL**: `POST /api/reset-password`
- **Body**: `{"token": "...", "newPassword": "..."}`
- **Response**: Success confirmation

## Testing Deep Links

### 1. Using Simulator

In the iOS Simulator, you can test deep links using these commands:

```bash
# Test forgot password link
xcrun simctl openurl booted "torny://forgot-password"

# Test reset password link with token
xcrun simctl openurl booted "torny://reset-password?token=sample-token-here"
```

### 2. Using Device

On a physical device, you can:

1. **Safari**: Type the URL directly: `torny://reset-password?token=abc123`
2. **Notes/Messages**: Create a link and tap it
3. **Email**: Ensure backend sends proper deep link URLs

### 3. Using Xcode

1. Set a breakpoint in `NavigationManager.handleDeepLink`
2. Run the app
3. Open Safari in simulator
4. Navigate to a deep link URL
5. Verify the breakpoint is hit

## User Flow

### Complete Password Reset Flow

1. **User requests reset**:
   - Taps "Forgot Password?" on login screen
   - Enters email address
   - Taps "Send Reset Link"

2. **User receives email**:
   - Email contains link: `torny://reset-password?token=abc123`
   - User taps link on their device

3. **App handles deep link**:
   - App opens (or comes to foreground)
   - NavigationManager processes URL
   - ResetPasswordView appears with token

4. **User resets password**:
   - Enters new password
   - Confirms password
   - Taps "Reset Password"
   - Success message appears
   - User is taken back to login

## Error Handling

### Common Scenarios

1. **Invalid Email**: Form validation prevents submission
2. **Network Error**: User-friendly network error message
3. **Expired Token**: Clear message with option to request new link
4. **Weak Password**: Real-time validation with requirements
5. **Server Error**: Display server-provided error message

### Testing Error Cases

```swift
// Test invalid token
let invalidTokenURL = URL(string: "torny://reset-password?token=invalid")!
navigationManager.handleDeepLink(invalidTokenURL)

// Test malformed URL
let malformedURL = URL(string: "torny://reset-password")! // No token
navigationManager.handleDeepLink(malformedURL)
```

## Security Considerations

1. **Token Expiration**: Tokens expire after 1 hour
2. **Single Use**: Tokens are invalidated after successful reset
3. **HTTPS Only**: All API calls use secure connections
4. **No Logging**: Sensitive data is not logged
5. **Memory Cleanup**: Tokens are cleared from memory after use

## Backend Requirements

Ensure your backend email templates include proper deep link URLs:

```html
<!-- Email template should include -->
<a href="torny://reset-password?token={{reset_token}}">
    Reset Your Password
</a>

<!-- Alternative for web browsers -->
<a href="https://your-website.com/reset-password?token={{reset_token}}">
    Reset Password (Web)
</a>
```

## Troubleshooting

### Deep Links Not Working

1. **Check URL Scheme**: Verify `torny` is registered in Info.plist
2. **Check Import**: Ensure NavigationManager is imported in TornyiOSApp
3. **Check Environment**: Verify NavigationManager is passed as environmentObject
4. **Check Device**: Deep links work differently on simulator vs device

### Password Reset Not Triggering

1. **Check Network**: Verify API endpoints are accessible
2. **Check Token**: Ensure token is properly extracted from URL
3. **Check Navigation**: Verify sheet presentations are working
4. **Check State**: Check NavigationManager published properties

### API Errors

1. **Check Base URL**: Verify correct API endpoint
2. **Check Headers**: Ensure Content-Type is set
3. **Check Body**: Verify JSON encoding
4. **Check Response**: Log response for debugging

## Analytics (Future Enhancement)

Consider tracking these events:

```swift
// Password reset request
Analytics.track("password_reset_requested", properties: [
    "email_domain": emailDomain
])

// Deep link opened
Analytics.track("password_reset_link_opened", properties: [
    "token_valid": tokenValid
])

// Password reset completed
Analytics.track("password_reset_completed", properties: [
    "success": true
])
```

## Next Steps

1. **Add URL scheme** to Info.plist in Xcode
2. **Test deep links** using simulator commands
3. **Test email flow** with backend integration
4. **Add analytics** for monitoring
5. **Add accessibility** labels and hints
6. **Test error scenarios** thoroughly

## Support

If you encounter issues:

1. Check console logs for error messages
2. Verify network connectivity
3. Test with valid vs invalid tokens
4. Ensure backend is returning proper responses
5. Verify deep link URL format matches expected pattern