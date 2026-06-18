//
//  CreatureNickname.swift
//  Dino Step Shared
//

import Foundation

enum CreatureNickname {
    static let maxLength = 24

    static func normalize(_ raw: String?) -> String? {
        let trimmed = String(raw?.trimmingCharacters(in: .whitespacesAndNewlines).prefix(maxLength) ?? "")
        return trimmed.isEmpty ? nil : trimmed
    }

    static func activeDisplayName(
        speciesName: String,
        nickname: String?,
        isHatched: Bool,
        mysteryEggTitle: String
    ) -> String {
        guard isHatched else { return mysteryEggTitle }
        return normalize(nickname) ?? speciesName
    }

    static func speciesSubtitle(
        speciesName: String,
        nickname: String?,
        isHatched: Bool
    ) -> String? {
        guard isHatched, normalize(nickname) != nil else { return nil }
        return speciesName
    }
}
