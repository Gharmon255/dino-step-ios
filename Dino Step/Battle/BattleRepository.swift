//
//  BattleRepository.swift
//  Dino Step
//

import Foundation

@MainActor
final class BattleRepository {
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

    func ensureProfile() async throws -> PlayerBattleProfile? {
        guard config.isConfigured, let session = sessionStore.loadSession() else { return nil }
        let json = try await httpClient.invokeBattleFunction(session: session, body: ["action": "ensureProfile"])
        guard let profile = json["profile"] as? [String: Any],
              let inviteCode = profile["invite_code"] as? String else {
            return nil
        }
        return PlayerBattleProfile(inviteCode: inviteCode, elo: profile["elo"] as? Int ?? 1000)
    }

    func createChallenge() async throws -> (BattleChallenge, String)? {
        guard config.isConfigured, let session = sessionStore.loadSession() else { return nil }
        let json = try await httpClient.invokeBattleFunction(session: session, body: ["action": "createChallenge"])
        guard let challengeJSON = json["challenge"] as? [String: Any],
              let challenge = decodeChallenge(challengeJSON),
              let inviteCode = json["inviteCode"] as? String else {
            return nil
        }
        return (challenge, inviteCode)
    }

    func acceptChallenge(inviteCode: String) async throws -> BattleChallenge? {
        guard config.isConfigured, let session = sessionStore.loadSession() else { return nil }
        let json = try await httpClient.invokeBattleFunction(
            session: session,
            body: ["action": "acceptChallenge", "inviteCode": inviteCode.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()]
        )
        guard let challengeJSON = json["challenge"] as? [String: Any] else { return nil }
        return decodeChallenge(challengeJSON)
    }

    func submitPick(challengeId: String, completedCreatureId: String) async throws -> (BattleChallenge, BattleRecord?) {
        guard config.isConfigured, let session = sessionStore.loadSession() else {
            throw SupabaseHTTPError.invalidResponse
        }
        let json = try await httpClient.invokeBattleFunction(
            session: session,
            body: [
                "action": "submitPick",
                "challengeId": challengeId,
                "completedCreatureId": completedCreatureId,
            ]
        )
        guard let challengeJSON = json["challenge"] as? [String: Any],
              let challenge = decodeChallenge(challengeJSON) else {
            throw SupabaseHTTPError.invalidResponse
        }
        let battle = (json["battle"] as? [String: Any]).flatMap(decodeBattle)
        return (challenge, battle)
    }

    func findQuickMatch(completedCreatureId: String) async throws -> BattleRecord? {
        guard config.isConfigured, let session = sessionStore.loadSession() else { return nil }
        let json = try await httpClient.invokeBattleFunction(
            session: session,
            body: ["action": "findQuickMatch", "completedCreatureId": completedCreatureId]
        )
        guard let battleJSON = json["battle"] as? [String: Any] else { return nil }
        return decodeBattle(battleJSON)
    }

    func listBattles() async throws -> [BattleRecord] {
        guard config.isConfigured, let session = sessionStore.loadSession() else { return [] }
        let json = try await httpClient.invokeBattleFunction(session: session, body: ["action": "listBattles"])
        guard let battles = json["battles"] as? [[String: Any]] else { return [] }
        return battles.compactMap(decodeBattle)
    }

    func getChallenge(challengeId: String) async throws -> BattleChallenge? {
        guard config.isConfigured, let session = sessionStore.loadSession() else { return nil }
        let json = try await httpClient.invokeBattleFunction(
            session: session,
            body: ["action": "getChallenge", "challengeId": challengeId]
        )
        guard let challengeJSON = json["challenge"] as? [String: Any] else { return nil }
        return decodeChallenge(challengeJSON)
    }

    func getBattle(battleId: String) async throws -> BattleRecord? {
        guard config.isConfigured, let session = sessionStore.loadSession() else { return nil }
        let json = try await httpClient.invokeBattleFunction(
            session: session,
            body: ["action": "getBattle", "battleId": battleId]
        )
        guard let battleJSON = json["battle"] as? [String: Any] else { return nil }
        return decodeBattle(battleJSON)
    }

    private func decodeChallenge(_ json: [String: Any]) -> BattleChallenge? {
        guard let data = try? JSONSerialization.data(withJSONObject: json),
              let challenge = try? JSONDecoder().decode(BattleChallenge.self, from: data) else {
            return nil
        }
        return challenge
    }

    private func decodeBattle(_ json: [String: Any]) -> BattleRecord? {
        guard let data = try? JSONSerialization.data(withJSONObject: json),
              let battle = try? JSONDecoder().decode(BattleRecord.self, from: data) else {
            return nil
        }
        return battle
    }
}
