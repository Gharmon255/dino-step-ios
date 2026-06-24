//
//  PromoRepository.swift
//  Dino Step
//

import Foundation

struct PromoRedeemResult {
    let pendingRewardEggRarity: Rarity
    let message: String
}

struct PromoStatusResult {
    let redeemed: Bool
    let rewardEggRarity: Rarity?
}

@MainActor
final class PromoRepository {
    private let config: SupabaseConfig
    private let httpClient: SupabaseHTTPClient
    private let sessionStore: CloudSessionStore

    init(
        config: SupabaseConfig = .shared,
        httpClient: SupabaseHTTPClient = SupabaseHTTPClient(),
        sessionStore: CloudSessionStore = CloudSessionStore()
    ) {
        self.config = config
        self.httpClient = httpClient
        self.sessionStore = sessionStore
    }

    func redeemCode(_ code: String) async throws -> PromoRedeemResult {
        guard config.isConfigured, let session = sessionStore.loadSession() else {
            throw PromoError.signInRequired
        }
        let json = try await httpClient.invokePromoFunction(
            session: session,
            body: ["action": "redeem", "code": code.trimmingCharacters(in: .whitespacesAndNewlines)]
        )
        let rarityRaw = (json["pendingRewardEggRarity"] as? String)
            ?? (json["rewardEggRarity"] as? String)
            ?? ""
        guard let rarity = Rarity(rawValue: rarityRaw) else {
            throw PromoError.invalidResponse
        }
        let message = json["message"] as? String
            ?? "Your next reward egg will be \(rarity.rawValue.lowercased())!"
        return PromoRedeemResult(pendingRewardEggRarity: rarity, message: message)
    }

    func status(code: String) async throws -> PromoStatusResult {
        guard config.isConfigured, let session = sessionStore.loadSession() else {
            throw PromoError.signInRequired
        }
        let json = try await httpClient.invokePromoFunction(
            session: session,
            body: ["action": "status", "code": code.trimmingCharacters(in: .whitespacesAndNewlines)]
        )
        let rewardRaw = json["rewardEggRarity"] as? String
        return PromoStatusResult(
            redeemed: json["redeemed"] as? Bool ?? false,
            rewardEggRarity: rewardRaw.flatMap(Rarity.init(rawValue:))
        )
    }
}

enum PromoError: LocalizedError {
    case signInRequired
    case invalidResponse

    var errorDescription: String? {
        switch self {
        case .signInRequired:
            return "Sign in required to redeem promo codes"
        case .invalidResponse:
            return "Could not redeem code"
        }
    }
}
