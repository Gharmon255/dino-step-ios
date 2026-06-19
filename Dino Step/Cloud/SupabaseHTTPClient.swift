//
//  SupabaseHTTPClient.swift
//  Dino Step
//

import Foundation

enum SupabaseHTTPError: LocalizedError {
    case invalidResponse
    case serverError(Int, String)

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid server response"
        case .serverError(let code, let body):
            return "Server error \(code): \(body)"
        }
    }
}

final class SupabaseHTTPClient {
    private let config: SupabaseConfig
    private let session: URLSession

    init(config: SupabaseConfig = .shared, session: URLSession = .shared) {
        self.config = config
        self.session = session
    }

    func signInWithIdToken(provider: String, idToken: String) async throws -> CloudSession {
        let body: [String: String] = [
            "provider": provider,
            "id_token": idToken,
        ]
        let json = try await post(path: "/auth/v1/token?grant_type=id_token", body: body, accessToken: nil)
        return parseSession(json: json, provider: provider)
    }

    func refreshSession(refreshToken: String) async throws -> CloudSession {
        let json = try await post(
            path: "/auth/v1/token?grant_type=refresh_token",
            body: ["refresh_token": refreshToken],
            accessToken: nil
        )
        return parseSession(json: json, provider: nil)
    }

    func fetchGameSave(authSession: CloudSession) async throws -> CloudSaveRow? {
        let base = config.url.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        var components = URLComponents(string: "\(base)/rest/v1/game_saves")!
        components.queryItems = [
            URLQueryItem(name: "user_id", value: "eq.\(authSession.userId)"),
            URLQueryItem(name: "select", value: "*"),
        ]
        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        addHeaders(&request, accessToken: authSession.accessToken)

        let (data, response) = try await session.data(for: request)
        try validate(response: response, data: data)
        guard let array = try JSONSerialization.jsonObject(with: data) as? [[String: Any]],
              let first = array.first else {
            return nil
        }
        return decodeRow(first)
    }

    func fetchUser(accessToken: String, refreshToken: String, provider: String?) async throws -> CloudSession {
        let base = config.url.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        var request = URLRequest(url: URL(string: "\(base)/auth/v1/user")!)
        request.httpMethod = "GET"
        addHeaders(&request, accessToken: accessToken)

        let (data, response) = try await session.data(for: request)
        try validate(response: response, data: data)
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw SupabaseHTTPError.invalidResponse
        }
        let appMetadata = json["app_metadata"] as? [String: Any]
        return CloudSession(
            userId: json["id"] as? String ?? "",
            accessToken: accessToken,
            refreshToken: refreshToken,
            email: json["email"] as? String,
            provider: provider ?? appMetadata?["provider"] as? String
        )
    }

    func upsertGameSave(authSession: CloudSession, row: CloudSaveRow) async throws {
        let base = config.url.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        var request = URLRequest(url: URL(string: "\(base)/rest/v1/game_saves")!)
        request.httpMethod = "POST"
        addHeaders(&request, accessToken: authSession.accessToken)
        request.setValue("resolution=merge-duplicates", forHTTPHeaderField: "Prefer")

        let saveDict = try encodeSave(row.save)
        let payload: [String: Any] = [
            "user_id": row.userId,
            "schema_version": row.schemaVersion,
            "revision": row.revision,
            "save_json": saveDict,
            "updated_at": row.updatedAt,
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: payload)

        let (data, response) = try await session.data(for: request)
        try validate(response: response, data: data)
    }

    private func post(path: String, body: [String: String], accessToken: String?) async throws -> [String: Any] {
        let base = config.url.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        var request = URLRequest(url: URL(string: "\(base)\(path)")!)
        request.httpMethod = "POST"
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        addHeaders(&request, accessToken: accessToken)

        let (data, response) = try await session.data(for: request)
        try validate(response: response, data: data)
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw SupabaseHTTPError.invalidResponse
        }
        return json
    }

    private func addHeaders(_ request: inout URLRequest, accessToken: String?) {
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(config.anonKey, forHTTPHeaderField: "apikey")
        if let accessToken {
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        }
    }

    private func validate(response: URLResponse, data: Data) throws {
        guard let http = response as? HTTPURLResponse else {
            throw SupabaseHTTPError.invalidResponse
        }
        guard (200...299).contains(http.statusCode) else {
            let body = String(data: data, encoding: .utf8) ?? ""
            throw SupabaseHTTPError.serverError(http.statusCode, body)
        }
    }

    private func parseSession(json: [String: Any], provider: String?) -> CloudSession {
        let user = json["user"] as? [String: Any] ?? [:]
        let appMetadata = user["app_metadata"] as? [String: Any]
        return CloudSession(
            userId: user["id"] as? String ?? "",
            accessToken: json["access_token"] as? String ?? "",
            refreshToken: json["refresh_token"] as? String ?? "",
            email: user["email"] as? String,
            provider: provider ?? appMetadata?["provider"] as? String
        )
    }

    private func decodeRow(_ json: [String: Any]) -> CloudSaveRow? {
        guard let userId = json["user_id"] as? String,
              let schemaVersion = json["schema_version"] as? Int,
              let revision = json["revision"] as? Int64 ?? (json["revision"] as? Int).map(Int64.init),
              let saveJson = json["save_json"] as? [String: Any],
              let updatedAt = json["updated_at"] as? String,
              let save = decodeSave(saveJson) else {
            return nil
        }
        return CloudSaveRow(
            userId: userId,
            schemaVersion: schemaVersion,
            revision: revision,
            save: save,
            updatedAt: updatedAt
        )
    }

    private func decodeSave(_ json: [String: Any]) -> CloudGameSave? {
        guard let data = try? JSONSerialization.data(withJSONObject: json),
              let save = try? JSONDecoder().decode(CloudGameSave.self, from: data) else {
            return nil
        }
        return save
    }

    private func encodeSave(_ save: CloudGameSave) throws -> [String: Any] {
        let data = try JSONEncoder().encode(save)
        guard let dict = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw SupabaseHTTPError.invalidResponse
        }
        return dict
    }
}
