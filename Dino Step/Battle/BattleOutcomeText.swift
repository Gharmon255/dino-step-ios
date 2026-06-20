//
//  BattleOutcomeText.swift
//  Dino Step
//

import Foundation

enum BattleOutcomeText {
    static func headline(for battle: BattleRecord, currentUserId: String?) -> String {
        let winner = battle.winner.lowercased()
        if winner == "draw" {
            return "Draw!"
        }
        guard let currentUserId else {
            return fallbackWinnerLabel(winner)
        }
        let mySide: String?
        if battle.playerAUserId == currentUserId {
            mySide = "a"
        } else if battle.playerBUserId == currentUserId {
            mySide = "b"
        } else {
            mySide = nil
        }
        guard let mySide else {
            return fallbackWinnerLabel(winner)
        }
        return mySide == winner ? "You win!" : "You lose!"
    }

    private static func fallbackWinnerLabel(_ winner: String) -> String {
        switch winner {
        case "a": return "Challenger wins"
        case "b": return "Opponent wins"
        default: return "Draw!"
        }
    }
}
