//
//  BattleModels.swift
//  Dino Step
//

import Foundation

struct BattleTurn: Codable, Equatable, Identifiable {
    var id: Int { turn }
    var turn: Int
    var actor: String
    var action: String
    var damage: Int
    var message: String
    var aHp: Int
    var bHp: Int
}

struct BattleRecord: Codable, Equatable, Identifiable {
    var id: String
    var mode: String
    var playerASpeciesId: String
    var playerBSpeciesId: String
    var playerAPower: Int
    var playerBPower: Int
    var winner: String
    var turnLog: [BattleTurn]
    var createdAt: String
    var playerAUserId: String
    var playerBUserId: String

    enum CodingKeys: String, CodingKey {
        case id
        case mode
        case playerASpeciesId = "player_a_species_id"
        case playerBSpeciesId = "player_b_species_id"
        case playerAPower = "player_a_power"
        case playerBPower = "player_b_power"
        case winner
        case turnLog = "turn_log"
        case createdAt = "created_at"
        case playerAUserId = "player_a_user_id"
        case playerBUserId = "player_b_user_id"
    }
}

struct BattleChallenge: Codable, Equatable, Identifiable {
    var id: String
    var status: String
    var challengerId: String
    var opponentId: String?
    var battleId: String?

    enum CodingKeys: String, CodingKey {
        case id
        case status
        case challengerId = "challenger_id"
        case opponentId = "opponent_id"
        case battleId = "battle_id"
    }
}

struct PlayerBattleProfile: Equatable {
    var inviteCode: String
    var elo: Int
}

enum BattleFeatures {
    static let enabled = true
}
