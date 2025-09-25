import Foundation
import Foundation

class APIService: ObservableObject {
    static let shared = APIService()
    
    private let trainingBaseURL = "https://ieg3lhlyy0.execute-api.ap-southeast-2.amazonaws.com/Prod/api/training"
    private let authBaseURL = "https://ieg3lhlyy0.execute-api.ap-southeast-2.amazonaws.com/Prod"
    @Published var authToken: String?
    @Published var isAuthenticated: Bool = false
    @Published var currentUser: User?
    
    // MARK: - Computed Properties for UI
    var userDisplayName: String {
        currentUser?.name ?? "User"
    }
    
    var userFirstName: String {
        currentUser?.firstName ?? "User"
    }
    
    var userEmail: String {
        currentUser?.email ?? ""
    }
    
    var userAvatarUrl: String? {
        guard let url = currentUser?.avatarUrl, !url.isEmpty else { return nil }
        return url
    }
    
    var hasAvatar: Bool {
        userAvatarUrl != nil && !userAvatarUrl!.isEmpty
    }
    
    private init() {
        loadAuthToken()
    }
    
    func setAuthToken(_ token: String) {
        self.authToken = token
    }
    
    private func makeRequest<T: Codable>(
        endpoint: String,
        method: HTTPMethod = .GET,
        body: Data? = nil,
        responseType: T.Type,
        useAuthBase: Bool = false
    ) async throws -> T {
        let baseURL = useAuthBase ? authBaseURL : trainingBaseURL
        guard let url = URL(string: baseURL + endpoint) else {
            throw APIError.invalidURL
        }
        
        print("📡 API Request: \(method.rawValue) \(url.absoluteString)")
        if let token = authToken {
            print("🔑 Auth Token: \(token)")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = authToken {
            // Always use Bearer token for authentication
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        if let body = body {
            request.httpBody = body
            if let bodyString = String(data: body, encoding: .utf8) {
                print("📤 Request Body: \(bodyString)")
            }
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        print("📥 Response Status: \(httpResponse.statusCode)")
        if let responseString = String(data: data, encoding: .utf8) {
            print("📥 Response Body: \(responseString)")
        }

        guard 200...299 ~= httpResponse.statusCode else {
            // Handle unauthorized (401) responses - token expired
            if httpResponse.statusCode == 401 {
                print("🔑 Received 401 unauthorized - clearing stored credentials")
                await MainActor.run {
                    clearAuthToken()
                }
                throw APIError.unauthorized
            }

            // Try to parse error message from response body
            if let errorData = try? JSONDecoder().decode(ErrorResponse.self, from: data),
               let message = errorData.message {
                throw APIError.serverErrorWithMessage(httpResponse.statusCode, message)
            }
            throw APIError.serverError(httpResponse.statusCode)
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .custom { decoder in
                let container = try decoder.singleValueContainer()
                let dateString = try container.decode(String.self)
                
                // Create formatters for different date formats
                let formatter1 = DateFormatter()
                formatter1.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                formatter1.locale = Locale(identifier: "en_US_POSIX")
                formatter1.timeZone = TimeZone(secondsFromGMT: 0)
                
                let formatter2 = DateFormatter()
                formatter2.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                formatter2.locale = Locale(identifier: "en_US_POSIX")
                formatter2.timeZone = TimeZone(secondsFromGMT: 0)
                
                let iso8601Formatter = ISO8601DateFormatter()
                
                // Try different formats
                if let date = formatter1.date(from: dateString) {
                    return date
                } else if let date = formatter2.date(from: dateString) {
                    return date
                } else if let date = iso8601Formatter.date(from: dateString) {
                    return date
                }
                
                throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode date string \(dateString)")
            }
            return try decoder.decode(responseType, from: data)
        } catch {
            print("❌ Decoding error for \(responseType): \(error)")
            if let dataString = String(data: data, encoding: .utf8) {
                print("❌ Failed to decode response: \(dataString)")
            }
            throw APIError.decodingError(error)
        }
    }
    
    // MARK: - Authentication Token Management
    
    private func loadAuthToken() {
        // First, try to migrate old UserDefaults tokens to Keychain
        migrateTokensFromUserDefaults()

        // Load token from secure Keychain storage
        if let token = KeychainService.shared.getAuthToken() {
            self.authToken = token
            self.isAuthenticated = true
            // Fetch current user profile when token is loaded
            Task {
                await fetchCurrentUserProfile()
            }
        } else {
            self.authToken = nil
            self.isAuthenticated = false
        }
    }

    /// Migrate existing tokens from UserDefaults to Keychain (one-time migration)
    private func migrateTokensFromUserDefaults() {
        // Check if we've already migrated
        if UserDefaults.standard.bool(forKey: "keychain_migration_completed") {
            return
        }

        // Migrate auth token
        if let token = UserDefaults.standard.string(forKey: "auth_token"),
           !token.isEmpty {
            let expiryDate = UserDefaults.standard.object(forKey: "token_expiry") as? Date ?? Date().addingTimeInterval(30 * 24 * 60 * 60)

            if KeychainService.shared.saveAuthToken(token, expiryDate: expiryDate) {
                print("🔑 Successfully migrated auth token to Keychain")

                // Migrate user ID if available
                if let userId = UserDefaults.standard.string(forKey: "current_user_id") {
                    KeychainService.shared.saveCurrentUserId(userId)
                    print("🔑 Successfully migrated user ID to Keychain")
                }

                // Clear old UserDefaults data
                UserDefaults.standard.removeObject(forKey: "auth_token")
                UserDefaults.standard.removeObject(forKey: "token_expiry")
                UserDefaults.standard.removeObject(forKey: "current_user_id")
                UserDefaults.standard.set(true, forKey: "keychain_migration_completed")

                print("🔑 Token migration completed and UserDefaults cleaned up")
            }
        } else {
            // No token to migrate, just mark migration as completed
            UserDefaults.standard.set(true, forKey: "keychain_migration_completed")
        }
    }

    private func fetchCurrentUserProfile() async {
        // Get user ID from secure Keychain storage
        guard let userIdString = KeychainService.shared.getCurrentUserId(),
              let userId = Int(userIdString) else {
            print("❌ No stored user ID found")
            return
        }

        do {
            let user = try await getUserProfile(userId)
            await MainActor.run {
                self.currentUser = user
                print("✅ Current user profile loaded: \(user.name)")
            }
        } catch {
            print("❌ Failed to load current user profile: \(error)")
            // If fetching fails, clear the stored data
            await MainActor.run {
                clearAuthToken()
            }
        }
    }
    
    private func saveAuthToken(_ token: String) {
        // Set token expiry to 30 days from now for extended session
        let expiryDate = Calendar.current.date(byAdding: .day, value: 30, to: Date()) ?? Date().addingTimeInterval(30 * 24 * 60 * 60)

        // Save token securely in Keychain
        if KeychainService.shared.saveAuthToken(token, expiryDate: expiryDate) {
            self.authToken = token
            self.isAuthenticated = true
            print("🔑 Token saved securely to Keychain with expiry: \(expiryDate)")
        } else {
            print("❌ Failed to save token to Keychain")
        }
    }
    
    private func clearAuthToken() {
        // Clear secure Keychain storage
        KeychainService.shared.clearAuthToken()

        // Also clear any remaining UserDefaults data (legacy cleanup)
        UserDefaults.standard.removeObject(forKey: "auth_token")
        UserDefaults.standard.removeObject(forKey: "current_user_id")
        UserDefaults.standard.removeObject(forKey: "token_expiry")

        self.authToken = nil
        self.isAuthenticated = false
        self.currentUser = nil

        print("🔑 Auth token cleared from all storage")
    }
    
    // MARK: - Authentication Methods
    
    func register(_ request: RegisterRequest) async throws -> RegisterResponse {
        let encoder = JSONEncoder()
        let data = try encoder.encode(request)
        
        let response: RegisterResponse = try await makeRequest(
            endpoint: "/register",
            method: .POST,
            body: data,
            responseType: RegisterResponse.self,
            useAuthBase: true
        )
        
        // Registration doesn't return a token, user needs to login separately
        print("✅ Registration successful: \(response.message)")
        
        return response
    }
    
    func login(_ request: LoginRequest) async throws -> AuthResponse {
        let encoder = JSONEncoder()
        let data = try encoder.encode(request)

        let response: AuthResponse = try await makeRequest(
            endpoint: "/login",
            method: .POST,
            body: data,
            responseType: AuthResponse.self,
            useAuthBase: true
        )

        saveAuthToken(response.token)
        // Store the user ID securely in Keychain for future profile loading
        KeychainService.shared.saveCurrentUserId(String(response.user.id))
        DispatchQueue.main.async {
            self.currentUser = response.user
            self.objectWillChange.send()
        }

        return response
    }
    
    func logout() {
        clearAuthToken()
    }

    func resetPassword(_ request: PasswordResetRequest) async throws {
        // TODO: Implement password reset functionality
        throw NSError(domain: "PasswordReset", code: 500, userInfo: [NSLocalizedDescriptionKey: "Password reset not implemented"])
    }

    func clearAllStoredData() {
        // Clear secure Keychain storage
        KeychainService.shared.clearAuthToken()

        // Also clear any remaining UserDefaults data (legacy cleanup)
        UserDefaults.standard.removeObject(forKey: "auth_token")
        UserDefaults.standard.removeObject(forKey: "current_user_id")
        UserDefaults.standard.removeObject(forKey: "token_expiry")

        self.authToken = nil
        self.isAuthenticated = false
        self.currentUser = nil

        print("🔑 All stored data cleared from secure storage")
    }

    // MARK: - Session Management

    /// Check if the current session is still valid
    func validateSession() -> Bool {
        return KeychainService.shared.isAuthTokenValid()
    }

    /// Get time remaining until session expires
    func sessionTimeRemaining() -> TimeInterval {
        return KeychainService.shared.getTokenTimeRemaining()
    }

    /// Check if session will expire soon (within 24 hours)
    func sessionExpiringSoon() -> Bool {
        return KeychainService.shared.isTokenExpiringSoon()
    }
    
    // MARK: - Profile Methods
    
    func updateProfile(userId: String, profile: ProfileUpdateRequest) async throws -> UpdateProfileResponse {
        let encoder = JSONEncoder()
        let data = try encoder.encode(profile)

        let response: UpdateProfileResponse = try await makeRequest(
            endpoint: "/profile/\(userId)",
            method: .PUT,
            body: data,
            responseType: UpdateProfileResponse.self,
            useAuthBase: true
        )

        // Since the update response doesn't return the full user data,
        // fetch the updated profile to refresh our data
        if response.status == "success" {
            if let userId = Int(userId) {
                let _ = try await getUserProfile(userId)
            }
        }

        return response
    }
    
    func getProfile(userId: String) async throws -> User {
        let response: ProfileResponse = try await makeRequest(
            endpoint: "/profile/\(userId)",
            method: .GET,
            responseType: ProfileResponse.self,
            useAuthBase: true
        )

        self.currentUser = response.data
        return response.data
    }
    
    // MARK: - Clubs Methods
    
    func searchClubs(name: String) async throws -> [Club] {
        guard name.count >= 3 else {
            return []
        }
        
        let baseURL = "https://ieg3lhlyy0.execute-api.ap-southeast-2.amazonaws.com/Prod"
        guard let url = URL(string: baseURL + "/clubs?name=\(name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&sport=1") else {
            throw APIError.invalidURL
        }
        
        print("📡 Clubs Search: GET \(url.absoluteString)")
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        print("📥 Clubs Response Status: \(httpResponse.statusCode)")
        if let responseString = String(data: data, encoding: .utf8) {
            print("📥 Clubs Response Body: \(responseString)")
        }
        
        guard 200...299 ~= httpResponse.statusCode else {
            // Try to parse error message from response body
            if let errorData = try? JSONDecoder().decode(ErrorResponse.self, from: data),
               let message = errorData.message {
                throw APIError.serverErrorWithMessage(httpResponse.statusCode, message)
            }
            throw APIError.serverError(httpResponse.statusCode)
        }
        
        do {
            let clubsResponse = try JSONDecoder().decode(ClubsSearchResponse.self, from: data)
            return clubsResponse.data
        } catch {
            print("❌ Clubs decoding error: \(error)")
            throw APIError.decodingError(error)
        }
    }
    
    func getUserProfile(_ userId: Int) async throws -> User {
        let response: ProfileResponse = try await makeRequest(
            endpoint: "/profile/\(userId)",
            responseType: ProfileResponse.self,
            useAuthBase: true
        )

        // Update currentUser if it's the same user
        if currentUser?.id == userId {
            currentUser = response.data
        }

        return response.data
    }
    
    // MARK: - Training Methods
    
    func createSession(_ session: CreateSessionRequest) async throws -> CreateSessionResponse {
        let encoder = JSONEncoder()
        let data = try encoder.encode(session)
        
        return try await makeRequest(
            endpoint: "/sessions",
            method: .POST,
            body: data,
            responseType: CreateSessionResponse.self
        )
    }
    
    func getSessions(limit: Int = 20, offset: Int = 0, dateFrom: String? = nil, dateTo: String? = nil) async throws -> SessionListResponse {
        var endpoint = "/sessions?limit=\(limit)&offset=\(offset)&sport=lawn_bowls"

        if let dateFrom = dateFrom {
            endpoint += "&dateFrom=\(dateFrom)"
        }
        if let dateTo = dateTo {
            endpoint += "&dateTo=\(dateTo)"
        }

        return try await makeRequest(
            endpoint: endpoint,
            responseType: SessionListResponse.self
        )
    }
    
    func getSessionDetails(_ sessionId: Int) async throws -> SessionDetailResponse {
        return try await makeRequest(
            endpoint: "/sessions/\(sessionId)",
            responseType: SessionDetailResponse.self
        )
    }
    
    func deleteSession(_ sessionId: Int) async throws -> DeleteResponse {
        return try await makeRequest(
            endpoint: "/sessions/\(sessionId)",
            method: .DELETE,
            responseType: DeleteResponse.self
        )
    }
    
    func endSession(_ sessionId: Int, request: EndSessionRequest) async throws -> CreateSessionResponse {
        let encoder = JSONEncoder()
        let data = try encoder.encode(request)
        
        return try await makeRequest(
            endpoint: "/sessions/\(sessionId)/end",
            method: .POST,
            body: data,
            responseType: CreateSessionResponse.self
        )
    }
    
    func getActiveSession() async throws -> CreateSessionResponse? {
        do {
            return try await makeRequest(
                endpoint: "/sessions/active",
                method: .GET,
                responseType: CreateSessionResponse.self
            )
        } catch {
            // If no active session, return nil instead of throwing
            return nil
        }
    }

    func getLiveChartData(sessionId: Int) async throws -> ChartDataResponse {
        return try await makeRequest(
            endpoint: "/sessions/\(sessionId)/chart-data",
            method: .GET,
            responseType: ChartDataResponse.self
        )
    }

    func getLiveChartViewData(sessionId: Int) async throws -> ChartViewData {
        let response = try await getLiveChartData(sessionId: sessionId)
        return convertToChartViewData(response)
    }

    private func convertToChartViewData(_ response: ChartDataResponse) -> ChartViewData {
        // Convert API response to ChartViewData
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        // Convert accuracy points
        let accuracyPoints = response.chartData.accuracyOverTime.map { point in
            let timestamp = dateFormatter.date(from: point.timestamp) ?? Date()
            return AccuracyPoint(shotNumber: point.x, cumulativeAccuracy: point.y, timestamp: timestamp)
        }

        // Convert shot type data
        let shotTypeData = response.chartData.shotTypeSeries
            .reduce(into: [String: (count: Int, total: Double)]()) { dict, series in
                if dict[series.type] == nil {
                    dict[series.type] = (count: 0, total: 0.0)
                }
                dict[series.type]!.count += 1
                dict[series.type]!.total += Double(series.score)
            }
            .map { (type, data) in
                let percentage = Double(data.count) / Double(response.totalShots) * 100.0
                let averageAccuracy = data.count > 0 ? data.total / Double(data.count) * 100.0 : 0.0
                return ShotTypeData(type: type, count: data.count, percentage: percentage, averageAccuracy: averageAccuracy)
            }

        // Convert recent shots
        let recentShots = response.chartData.shotTypeSeries.suffix(10).enumerated().map { (index, series) in
            let timestamp = dateFormatter.date(from: series.timestamp) ?? Date()
            return RecentShotData(
                shotNumber: series.x,
                type: series.type,
                points: series.score,
                distanceFromTarget: nil,
                notes: nil,
                timestamp: timestamp,
                wasSuccessful: series.score > 0
            )
        }

        // Create performance metrics
        let successfulShots = response.currentScore
        let currentStreak = calculateCurrentStreak(from: response.chartData.shotTypeSeries)
        let bestStreak = calculateBestStreak(from: response.chartData.shotTypeSeries)

        let metrics = PerformanceMetrics(
            totalShots: response.totalShots,
            successfulShots: successfulShots,
            overallAccuracy: response.overallAccuracy,
            currentStreak: currentStreak,
            bestStreak: bestStreak,
            averageDistanceFromTarget: nil,
            improvementTrend: determineImprovementTrend(from: accuracyPoints)
        )

        // Create metadata
        let lastUpdated = dateFormatter.date(from: response.lastUpdated) ?? Date()
        let sessionStart = dateFormatter.date(from: response.startedAt) ?? Date()

        let metadata = ChartMetadata(
            lastUpdated: lastUpdated,
            sessionStartTime: sessionStart,
            refreshIntervalSeconds: 30,
            dataPoints: response.totalShots
        )

        return ChartViewData(
            accuracyPoints: accuracyPoints,
            shotTypeData: shotTypeData,
            metrics: metrics,
            recentShots: recentShots,
            metadata: metadata
        )
    }

    private func calculateCurrentStreak(from series: [ShotTypeSeries]) -> Int {
        var streak = 0
        for shot in series.reversed() {
            if shot.score > 0 {
                streak += 1
            } else {
                break
            }
        }
        return streak
    }

    private func calculateBestStreak(from series: [ShotTypeSeries]) -> Int {
        var bestStreak = 0
        var currentStreak = 0

        for shot in series {
            if shot.score > 0 {
                currentStreak += 1
                bestStreak = max(bestStreak, currentStreak)
            } else {
                currentStreak = 0
            }
        }

        return bestStreak
    }

    private func determineImprovementTrend(from accuracyPoints: [AccuracyPoint]) -> String {
        guard accuracyPoints.count >= 3 else { return "stable" }

        let recentPoints = accuracyPoints.suffix(3)
        let firstAccuracy = recentPoints.first?.cumulativeAccuracy ?? 0
        let lastAccuracy = recentPoints.last?.cumulativeAccuracy ?? 0

        let change = lastAccuracy - firstAccuracy

        if change > 5.0 {
            return "improving"
        } else if change < -5.0 {
            return "declining"
        } else {
            return "stable"
        }
    }

    func recordShot(_ shot: RecordShotRequest) async throws -> RecordShotResponse {
        let encoder = JSONEncoder()
        let data = try encoder.encode(shot)
        
        return try await makeRequest(
            endpoint: "/shots",
            method: .POST,
            body: data,
            responseType: RecordShotResponse.self
        )
    }
    
    func deleteShot(_ shotId: Int) async throws -> DeleteShotResponse {
        return try await makeRequest(
            endpoint: "/shots/\(shotId)",
            method: .DELETE,
            responseType: DeleteShotResponse.self
        )
    }
    
    func getTrainingStats(period: String = "all", shotType: String? = nil) async throws -> TrainingStatsResponse {
        var endpoint = "/stats?period=\(period)"
        
        if let shotType = shotType {
            endpoint += "&shot_type=\(shotType)"
        }
        
        return try await makeRequest(
            endpoint: endpoint,
            responseType: TrainingStatsResponse.self
        )
    }
    
    func getTrainingProgress(groupBy: String = "week", limit: Int = 12) async throws -> TrainingProgressResponse {
        let endpoint = "/progress?group_by=\(groupBy)&limit=\(limit)"

        return try await makeRequest(
            endpoint: endpoint,
            responseType: TrainingProgressResponse.self
        )
    }

    // MARK: - Analytics Methods

    func getComparativeAnalytics(query: ComparativeAnalyticsQuery) async throws -> ComparativeAnalyticsResponse {
        var components = URLComponents()
        components.queryItems = query.queryItems
        let queryString = components.percentEncodedQuery ?? ""

        return try await makeRequest(
            endpoint: "/analytics/comparative?\(queryString)",
            responseType: ComparativeAnalyticsResponse.self
        )
    }

    func getProgressChartData(query: ProgressChartQuery) async throws -> ProgressChartResponse {
        var components = URLComponents()
        components.queryItems = query.queryItems
        let queryString = components.percentEncodedQuery ?? ""

        return try await makeRequest(
            endpoint: "/progress/chart?\(queryString)",
            responseType: ProgressChartResponse.self
        )
    }
}

enum HTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case DELETE = "DELETE"
}

enum APIError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case serverError(Int)
    case serverErrorWithMessage(Int, String)
    case decodingError(Error)
    case unauthorized

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response"
        case .serverError(let code):
            return "Server error: \(code)"
        case .serverErrorWithMessage(_, let message):
            return message
        case .decodingError(let error):
            return "Decoding error: \(error.localizedDescription)"
        case .unauthorized:
            return "Your session has expired. Please log in again."
        }
    }
}