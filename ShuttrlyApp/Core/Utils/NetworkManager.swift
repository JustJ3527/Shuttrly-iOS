//
//  NetworkManager.swift
//  ShuttrlyApp
//
//  Created by Jules Antoine on 28/08/2025.
//

import Foundation
import Combine

// MARK: - Network Manager
// Centralized network layer for all API calls to Django backend

class NetworkManager: ObservableObject {
    
    // MARK: - Properties
    
    // Shared instance for singleton access
    static let shared = NetworkManager()
    
    // Session Configuration
    private let session: URLSession
    
    // MARK: - Initialization
    
    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = AppConstants.API.timeout
        config.timeoutIntervalForResource = 60
        session = URLSession(configuration: config)
    }
    
    // MARK: - Generic API Call Method
    
    /// Perform a request with a request body
    func performRequest<T: Codable, U: Codable>(
        endpoint: String,
        method: HTTPMethod = .GET,
        requestBody: T? = nil,
        responseType: U.Type
    ) -> AnyPublisher<U, NetworkError> {
        
        // Build URL using AppConstants
        guard let url = URL(string: "\(AppConstants.API.baseURL)\(endpoint)") else {
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }
        
        // Create request
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Add authorization header if available
        if let token = getStoredAccessToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        // Add request body if provided (only for non-GET requests)
        if let requestBody = requestBody, method != .GET {
           do {
               request.httpBody = try JSONEncoder().encode(requestBody)
           } catch {
               return Fail(error: NetworkError.encodingError(error))
                   .eraseToAnyPublisher()
           }
        }
        
        // Perform request
        return session.dataTaskPublisher(for: request).tryMap { data, response in
            // Check HTTP status code
            if let httpResponse = response as? HTTPURLResponse {
                print("🌐 HTTP Response: \(httpResponse.statusCode)")
                print("📊 Response size: \(data.count) bytes")
                
                switch httpResponse.statusCode {
                case 200...299:
                    // Print raw response for debugging
                    if let responseString = String(data: data, encoding: .utf8) {
                        print("📥 Raw response: \(responseString)")
                    }
                    return data
                case 400:
                    // Parse structured error response from API
                    if let responseString = String(data: data, encoding: .utf8) {
                        print("📥 Error response: \(responseString)")
                        // Try to parse structured error
                        if let errorData = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                            throw NetworkError.apiError(errorData)
                        }
                    }
                    throw NetworkError.httpError(httpResponse.statusCode)
                case 401:
                    // Don't throw unauthorized error for session refresh endpoint
                    // This allows the app to continue working even if refresh fails
                    if endpoint.contains("refresh-session") {
                        return data
                    }
                    throw NetworkError.unauthorized
                case 403:
                    throw NetworkError.forbidden
                case 404:
                    throw NetworkError.notFound
                case 422:
                    throw NetworkError.validationError
                case 500...599:
                    throw NetworkError.serverError
                default:
                    throw NetworkError.httpError(httpResponse.statusCode)
                }
            }
            throw NetworkError.invalidResponse
        }
        .decode(type: responseType, decoder: JSONDecoder())
        .mapError { error in
            print("🔴 Decoding error: \(error)")
            if let decodingError = error as? DecodingError {
                switch decodingError {
                case .keyNotFound(let key, let context):
                    print("❌ Key '\(key)' not found: \(context.debugDescription)")
                case .typeMismatch(let type, let context):
                    print("❌ Type mismatch for '\(type)': \(context.debugDescription)")
                case .valueNotFound(let type, let context):
                    print("❌ Value not found for '\(type)': \(context.debugDescription)")
                case .dataCorrupted(let context):
                    print("❌ Data corrupted: \(context.debugDescription)")
                @unknown default:
                    print("❌ Unknown decoding error: \(error)")
                }
            }
            
            if let networkError = error as? NetworkError {
                return networkError
            }
            return NetworkError.decodingError(error)
        }
        .eraseToAnyPublisher()
    }
    
    /// Perform a GET request without a request body
    func performRequest<U: Codable>(
        endpoint: String,
        method: HTTPMethod = .GET,
        responseType: U.Type
    ) -> AnyPublisher<U, NetworkError> {
        
        // Build URL using AppConstants
        guard let url = URL(string: "\(AppConstants.API.baseURL)\(endpoint)") else {
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }
        
        // Create request
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Add authorization header if available
        if let token = getStoredAccessToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        // Perform request
        return session.dataTaskPublisher(for: request).tryMap { data, response in
            // Check HTTP status code
            if let httpResponse = response as? HTTPURLResponse {
                print("🌐 HTTP Response: \(httpResponse.statusCode)")
                print("📊 Response size: \(data.count) bytes")
                
                switch httpResponse.statusCode {
                case 200...299:
                    // Print raw response for debugging
                    if let responseString = String(data: data, encoding: .utf8) {
                        print("📥 Raw response: \(responseString)")
                    }
                    return data
                case 400:
                    // Parse structured error response from API
                    if let responseString = String(data: data, encoding: .utf8) {
                        print("📥 Error response: \(responseString)")
                        // Try to parse structured error
                        if let errorData = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                            throw NetworkError.apiError(errorData)
                        }
                    }
                    throw NetworkError.httpError(httpResponse.statusCode)
                case 401:
                    throw NetworkError.unauthorized
                case 403:
                    throw NetworkError.forbidden
                case 404:
                    throw NetworkError.notFound
                case 422:
                    throw NetworkError.validationError
                case 500...599:
                    throw NetworkError.serverError
                default:
                    throw NetworkError.httpError(httpResponse.statusCode)
                }
            }
            throw NetworkError.invalidResponse
        }
        .decode(type: responseType, decoder: JSONDecoder())
        .mapError { error in
            print("🔴 Decoding error: \(error)")
            if let decodingError = error as? DecodingError {
                switch decodingError {
                case .keyNotFound(let key, let context):
                    print("❌ Key '\(key)' not found: \(context.debugDescription)")
                case .typeMismatch(let type, let context):
                    print("❌ Type mismatch for '\(type)': \(context.debugDescription)")
                case .valueNotFound(let type, let context):
                    print("❌ Value not found for '\(type)': \(context.debugDescription)")
                case .dataCorrupted(let context):
                    print("❌ Data corrupted: \(context.debugDescription)")
                @unknown default:
                    print("❌ Unknown decoding error: \(error)")
                }
            }
            
            if let networkError = error as? NetworkError {
                return networkError
            }
            return NetworkError.decodingError(error)
        }
        .eraseToAnyPublisher()
    }
    
    // MARK: - Custom Request Method
    
    /// Perform a custom request (e.g., for file uploads)
    func performCustomRequest(_ request: URLRequest) -> AnyPublisher<Data, NetworkError> {
        return session.dataTaskPublisher(for: request).tryMap { data, response in
            // Check HTTP status code
            if let httpResponse = response as? HTTPURLResponse {
                print("🌐 HTTP Response: \(httpResponse.statusCode)")
                print("📊 Response size: \(data.count) bytes")
                
                switch httpResponse.statusCode {
                case 200...299:
                    return data
                case 401:
                    // For custom requests, we don't have endpoint info, so always throw unauthorized
                    throw NetworkError.unauthorized
                case 403:
                    throw NetworkError.forbidden
                case 404:
                    throw NetworkError.notFound
                case 422:
                    throw NetworkError.validationError
                case 500...599:
                    throw NetworkError.serverError
                default:
                    throw NetworkError.httpError(httpResponse.statusCode)
                }
            }
            throw NetworkError.invalidResponse
        }
        .mapError { error in
            if let networkError = error as? NetworkError {
                return networkError
            }
            return NetworkError.httpError(500)
        }
        .eraseToAnyPublisher()
    }
    
    // MARK: - Token Management
    
    private func getStoredAccessToken() -> String? {
        return UserDefaults.standard.string(forKey: AppConstants.StorageKeys.accessToken)
    }
    
    func clearStoredTokens() {
        UserDefaults.standard.removeObject(forKey: AppConstants.StorageKeys.accessToken)
        UserDefaults.standard.removeObject(forKey: AppConstants.StorageKeys.refreshToken)
    }
}

// MARK: - Supporting Types

enum HTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case DELETE = "DELETE"
}

enum NetworkError: LocalizedError {
    case invalidURL
    case invalidResponse
    case unauthorized
    case forbidden
    case notFound
    case validationError
    case serverError
    case httpError(Int)
    case apiError([String: Any])  // Structured API error response
    case encodingError(Error)
    case decodingError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .unauthorized:
            return "Unauthorized - Please log in again"
        case .forbidden:
            return "Access forbidden"
        case .notFound:
            return "Resource not found"
        case .validationError:
            return "Validation error - Please check your input"
        case .serverError:
            return "Server error - Please try again later"
        case .httpError(let code):
            return "HTTP error: \(code)"
        case .apiError(let errorData):
            // Extract user-friendly message from structured API error
            if let error = errorData["error"] as? [String: Any],
               let message = error["message"] as? String {
                return message
            }
            return "API error occurred"
        case .encodingError(let error):
            return "Encoding error: \(error.localizedDescription)"
        case .decodingError(let error):
            return "Decoding error: \(error.localizedDescription)"
        }
    }
}
