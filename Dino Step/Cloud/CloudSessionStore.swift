//
//  CloudSessionStore.swift
//  Dino Step
//

import Foundation
import Security

final class CloudSessionStore {
    private let service = "com.gharmon255.Dino-Step.cloud-session"

    func loadSession() -> CloudSession? {
        guard let data = read(key: "session"),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: String],
              let userId = json["userId"],
              let accessToken = json["accessToken"],
              let refreshToken = json["refreshToken"] else {
            return nil
        }
        return CloudSession(
            userId: userId,
            accessToken: accessToken,
            refreshToken: refreshToken,
            email: json["email"],
            provider: json["provider"]
        )
    }

    func saveSession(_ session: CloudSession) {
        let json: [String: String] = [
            "userId": session.userId,
            "accessToken": session.accessToken,
            "refreshToken": session.refreshToken,
            "email": session.email ?? "",
            "provider": session.provider ?? "",
        ]
        guard let data = try? JSONSerialization.data(withJSONObject: json) else { return }
        write(data: data, key: "session")
    }

    func clear() {
        delete(key: "session")
    }

    private func write(data: Data, key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
        ]
        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }

    private func read(key: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
        ]
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess else { return nil }
        return item as? Data
    }

    private func delete(key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
        ]
        SecItemDelete(query as CFDictionary)
    }
}
