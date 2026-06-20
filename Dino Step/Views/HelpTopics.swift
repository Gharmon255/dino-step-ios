//
//  HelpTopics.swift
//  Dino Step
//

import Foundation

struct HelpSection: Identifiable {
    var id: String { title }
    let title: String
    let body: String
}

enum HelpTopics {
    static func sections(includeEggsTab: Bool) -> [HelpSection] {
        var sections: [HelpSection] = [
            HelpSection(
                title: "Getting started",
                body: """
                Walk every day to earn steps. Tap Sync Steps on Home to pull steps from Apple Health. \
                Steps hatch your egg and grow your active dinosaur through baby, juvenile, and adult stages.
                """
            ),
            HelpSection(
                title: "Home",
                body: """
                Your active egg or dinosaur lives here. Watch cracks appear on the egg as you walk. \
                After hatching, see growth stages, nicknames, and your Dino Dex progress. \
                Duplicate adults can be traded for a new egg of the same rarity.
                """
            ),
        ]

        if includeEggsTab {
            sections.append(
                HelpSection(
                    title: "Eggs",
                    body: """
                    See which species can hatch from your current egg rarity and how many steps each \
                    milestone needs. Rarer eggs take more walking but can become stronger dinos.
                    """
                )
            )
        }

        sections.append(contentsOf: [
            HelpSection(
                title: "Collection",
                body: """
                Every adult you claim is saved here. Tap a species to see stats, EX level, and pack size. \
                Owning duplicates of the same species makes that fighter stronger in battles.
                """
            ),
            HelpSection(
                title: "Battle",
                body: """
                Sign in from Stats to battle (optional). Pick an adult fighter, then either Quick match \
                for an instant fight or Challenge a friend:

                • Host taps Challenge and shares the 5-letter code
                • Friend enters the code and taps Accept & blind pick
                • Both lock in a fighter — picks stay hidden until the reveal

                Friend battles need two different accounts (different emails).
                """
            ),
            HelpSection(
                title: "Stats & backup",
                body: """
                View today's steps, lifetime steps, and dex progress. Optionally sign in to back up your \
                save to the cloud or export a local copy. Grant Health permissions here if sync is blocked.
                """
            ),
            HelpSection(
                title: "Daily step goal",
                body: """
                Walk at least 5,000 steps on a day or your active dinosaur resets to a fresh egg with \
                500 steps already applied. Keep moving to protect your progress!
                """
            ),
        ])

        return sections
    }
}

enum BattleIntroContent {
    static let title = "How battles work"

    static let body = """
    Battle with a friend using blind picks — neither player sees the other's fighter until the fight ends.

    1. Sign in from Stats (both players).
    2. Host taps Challenge and shares the 5-letter code.
    3. Friend enters the code and taps Accept & blind pick.
    4. Both lock in an adult from their collection.
    5. Stronger fighter wins — rarity, EX, and pack bonuses all matter.

    Use two different accounts on two phones (different emails).
    """
}
