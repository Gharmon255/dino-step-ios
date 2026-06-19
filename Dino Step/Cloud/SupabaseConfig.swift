//
//  SupabaseConfig.swift
//  Dino Step
//

import Foundation

struct SupabaseConfig {
    let url: String
    let anonKey: String
    let googleOAuthRedirect: String

    var isConfigured: Bool {
        !url.isEmpty && !anonKey.isEmpty
    }

    static let shared: SupabaseConfig = {
        if let plistURL = Bundle.main.url(forResource: "SupabaseConfig", withExtension: "plist"),
           let data = try? Data(contentsOf: plistURL),
           let plist = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any] {
            return SupabaseConfig(
                url: plist["SUPABASE_URL"] as? String ?? "",
                anonKey: plist["SUPABASE_ANON_KEY"] as? String ?? "",
                googleOAuthRedirect: plist["GOOGLE_OAUTH_REDIRECT"] as? String ?? "stepasaurus://auth-callback"
            )
        }
        return SupabaseConfig(url: "", anonKey: "", googleOAuthRedirect: "stepasaurus://auth-callback")
    }()
}
