//
//  BattleUIComponents.swift
//  Dino Step
//

import SwiftUI

// MARK: - Arena & chrome

struct BattleArenaBackground: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color(red: 0.08, green: 0.14, blue: 0.28),
                Color(red: 0.12, green: 0.28, blue: 0.22),
                Color(red: 0.06, green: 0.10, blue: 0.14),
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay {
            RadialGradient(
                colors: [Color.white.opacity(0.08), .clear],
                center: .top,
                startRadius: 20,
                endRadius: 320
            )
        }
        .ignoresSafeArea()
    }
}

struct BattleSectionHeader: View {
    let title: String
    var subtitle: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.title3.weight(.bold))
                .foregroundStyle(.white)
            if let subtitle {
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.72))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct BattleStatusBanner: View {
    let message: String

    private var isWaiting: Bool {
        message.localizedCaseInsensitiveContains("waiting")
    }

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: isWaiting ? "hourglass" : "bolt.fill")
                .foregroundStyle(isWaiting ? .yellow : .green)
            Text(message)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white)
                .multilineTextAlignment(.leading)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white.opacity(0.12))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(Color.white.opacity(0.18), lineWidth: 1)
                )
        )
    }
}

struct BattleSignInPrompt: View {
    var body: some View {
        GameCard {
            VStack(spacing: 14) {
                Image(systemName: "person.crop.circle.badge.checkmark")
                    .font(.system(size: 44))
                    .foregroundStyle(.yellow)
                Text("Sign in to enter the arena")
                    .font(.headline)
                Text("Open Stats and sign in with Apple to battle other players. Gameplay works offline without an account.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

// MARK: - Battle code

struct BattleCodeBanner: View {
    let code: String

    var body: some View {
        VStack(spacing: 12) {
            Text("SHARE THIS CODE")
                .font(.caption.weight(.heavy))
                .foregroundStyle(.yellow.opacity(0.9))
                .tracking(1.2)

            HStack(spacing: 8) {
                ForEach(Array(code.uppercased()), id: \.self) { character in
                    Text(String(character))
                        .font(.system(size: 28, weight: .black, design: .monospaced))
                        .foregroundStyle(.white)
                        .frame(width: 46, height: 54)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color(red: 0.2, green: 0.45, blue: 0.95),
                                            Color(red: 0.12, green: 0.28, blue: 0.72),
                                        ],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .strokeBorder(Color.white.opacity(0.35), lineWidth: 1.5)
                                )
                        )
                        .shadow(color: .black.opacity(0.25), radius: 4, y: 2)
                }
            }

            Text("New code each Challenge · opponent taps Accept")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.65))
                .multilineTextAlignment(.center)
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.black.opacity(0.28))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .strokeBorder(Color.yellow.opacity(0.35), lineWidth: 1)
                )
        )
    }
}

// MARK: - Fighter selection

struct BattleFighterCard: View {
    let fighter: CompletedCreature
    let collection: [CompletedCreature]
    let selected: Bool
    let onSelect: () -> Void

    private var power: FighterPower {
        BattlePowerCalculator.compute(fighter: fighter, collection: collection)
    }

    private var rarityColor: Color {
        RarityColors.color(for: fighter.definition.rarity)
    }

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(rarityColor.opacity(0.22))
                        .frame(width: 72, height: 72)
                    CreatureStageVisualView(
                        creature: fighter.definition,
                        stage: .adult,
                        eggRarity: fighter.eggRarityAtHatch,
                        compact: true,
                        fixedVisualSize: 58
                    )
                }

                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Text(fighter.displayName)
                            .font(.headline)
                            .foregroundStyle(.primary)
                        Text(fighter.definition.rarity.rawValue)
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(rarityColor)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Capsule().fill(rarityColor.opacity(0.18)))
                    }

                    BattleStatBar(
                        label: "CP",
                        value: power.combatPower,
                        maxValue: max(power.combatPower, 300),
                        tint: rarityColor
                    )

                    HStack(spacing: 12) {
                        BattleMiniStat(icon: "star.fill", label: "EX", value: "\(power.exLevel)")
                        BattleMiniStat(icon: "person.3.fill", label: "Pack", value: "×\(power.packCount)")
                        if power.packCount > 1 {
                            Text(BattlePowerCalculator.packAbilityLabel(speciesId: power.speciesId))
                                .font(.caption2.weight(.semibold))
                                .foregroundStyle(.orange)
                        }
                    }
                }

                Spacer(minLength: 0)

                Image(systemName: selected ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(selected ? .yellow : Color.secondary.opacity(0.45))
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.secondarySystemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(
                                selected ? Color.yellow : rarityColor.opacity(0.25),
                                lineWidth: selected ? 2.5 : 1
                            )
                    )
                    .shadow(color: selected ? Color.yellow.opacity(0.25) : .clear, radius: 8)
            )
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.18), value: selected)
    }
}

struct BattleStatBar: View {
    let label: String
    let value: Int
    let maxValue: Int
    let tint: Color

    private var fraction: CGFloat {
        guard maxValue > 0 else { return 0 }
        return min(1, CGFloat(value) / CGFloat(maxValue))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(label)
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(value)")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(tint)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.black.opacity(0.12))
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [tint.opacity(0.85), tint],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * fraction)
                }
            }
            .frame(height: 8)
        }
    }
}

struct BattleMiniStat: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption2)
                .foregroundStyle(.secondary)
            Text("\(label) \(value)")
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Actions

struct BattleActionButton: View {
    enum Style {
        case primary
        case secondary
        case accent
    }

    let title: String
    let systemImage: String
    var style: Style = .primary
    var disabled: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(backgroundGradient.opacity(disabled ? 0.35 : 1))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(Color.white.opacity(0.2), lineWidth: 1)
                )
        }
        .disabled(disabled)
        .buttonStyle(.plain)
    }

    private var backgroundGradient: LinearGradient {
        switch style {
        case .primary:
            LinearGradient(colors: [Color(red: 0.18, green: 0.55, blue: 0.32), Color(red: 0.10, green: 0.38, blue: 0.24)], startPoint: .top, endPoint: .bottom)
        case .secondary:
            LinearGradient(colors: [Color(red: 0.28, green: 0.32, blue: 0.42), Color(red: 0.18, green: 0.22, blue: 0.30)], startPoint: .top, endPoint: .bottom)
        case .accent:
            LinearGradient(colors: [Color(red: 0.85, green: 0.55, blue: 0.12), Color(red: 0.65, green: 0.38, blue: 0.08)], startPoint: .top, endPoint: .bottom)
        }
    }
}

struct BattleJoinCodeField: View {
    @Binding var code: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Opponent's battle code")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white.opacity(0.75))

            TextField("ABCDE", text: $code)
                .font(.system(.title2, design: .monospaced).weight(.bold))
                .multilineTextAlignment(.center)
                .textInputAutocapitalization(.characters)
                .autocorrectionDisabled()
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.black.opacity(0.22))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .strokeBorder(Color.white.opacity(0.2), lineWidth: 1)
                        )
                )
                .foregroundStyle(.white)
                .onChange(of: code) { _, newValue in
                    let filtered = newValue.uppercased().filter { $0.isLetter || $0.isNumber }
                    code = String(filtered.prefix(5))
                }
        }
    }
}

// MARK: - Battle reveal

struct BattleRevealCard: View {
    let battle: BattleRecord
    let headline: String
    let currentUserId: String?

    @State private var revealed = false

    private var fighterA: CreatureDefinition? {
        CreatureCatalog.creature(withSpeciesId: battle.playerASpeciesId)
    }

    private var fighterB: CreatureDefinition? {
        CreatureCatalog.creature(withSpeciesId: battle.playerBSpeciesId)
    }

    private var mySide: String? {
        BattleSideHelper.side(for: currentUserId, in: battle)
    }

    private var outcomeStyle: OutcomeStyle {
        OutcomeStyle(headline: headline)
    }

    private var lastTurn: BattleTurn? {
        battle.turnLog.last
    }

    var body: some View {
        VStack(spacing: 0) {
            outcomeHeader

            HStack(alignment: .top, spacing: 0) {
                fighterColumn(
                    definition: fighterA,
                    speciesId: battle.playerASpeciesId,
                    power: battle.playerAPower,
                    hp: lastTurn?.aHp ?? 0,
                    side: "a",
                    alignment: .leading
                )

                vsBadge

                fighterColumn(
                    definition: fighterB,
                    speciesId: battle.playerBSpeciesId,
                    power: battle.playerBPower,
                    hp: lastTurn?.bHp ?? 0,
                    side: "b",
                    alignment: .trailing
                )
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 16)

            battleLogPanel
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.14, green: 0.18, blue: 0.28),
                            Color(red: 0.08, green: 0.12, blue: 0.18),
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .strokeBorder(outcomeStyle.borderColor.opacity(0.55), lineWidth: 2)
                )
                .shadow(color: outcomeStyle.borderColor.opacity(0.35), radius: 12, y: 4)
        )
        .scaleEffect(revealed ? 1 : 0.94)
        .opacity(revealed ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.78)) {
                revealed = true
            }
        }
    }

    private var outcomeHeader: some View {
        VStack(spacing: 6) {
            Text(headline.uppercased())
                .font(.system(size: 26, weight: .black, design: .rounded))
                .foregroundStyle(outcomeStyle.textGradient)
                .shadow(color: .black.opacity(0.35), radius: 2, y: 2)
            Text(battle.mode == "friend" ? "Friend battle" : "Quick match")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white.opacity(0.55))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .background(
            LinearGradient(
                colors: [outcomeStyle.borderColor.opacity(0.35), .clear],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }

    private var vsBadge: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [.yellow, .orange],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 44, height: 44)
                .shadow(color: .orange.opacity(0.5), radius: 6)
            Text("VS")
                .font(.system(size: 14, weight: .black, design: .rounded))
                .foregroundStyle(.white)
        }
        .padding(.top, 28)
    }

    @ViewBuilder
    private func fighterColumn(
        definition: CreatureDefinition?,
        speciesId: String,
        power: Int,
        hp: Int,
        side: String,
        alignment: HorizontalAlignment
    ) -> some View {
        let isWinner = battle.winner == side
        let isMe = mySide == side
        let maxHp = max(1, Int(Double(power) * 1.2))
        let name = definition?.name ?? speciesId
        let rarity = definition?.rarity ?? .common
        let color = RarityColors.color(for: rarity)

        VStack(spacing: 8) {
            if isMe {
                Text("YOU")
                    .font(.caption2.weight(.black))
                    .foregroundStyle(.black)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Capsule().fill(.yellow))
            }

            ZStack {
                Circle()
                    .fill(color.opacity(isWinner ? 0.35 : 0.18))
                    .frame(width: 88, height: 88)
                    .overlay(
                        Circle()
                            .strokeBorder(isWinner ? Color.yellow : color.opacity(0.4), lineWidth: isWinner ? 3 : 1)
                    )
                if let definition {
                    CreatureStageVisualView(
                        creature: definition,
                        stage: .adult,
                        compact: true,
                        fixedVisualSize: 72
                    )
                }
            }

            Text(name)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(.white)
                .multilineTextAlignment(alignment == .leading ? .leading : .trailing)
                .lineLimit(2)
                .frame(maxWidth: .infinity, alignment: alignment == .leading ? .leading : .trailing)

            BattleHPBar(current: hp, maxHp: maxHp, tint: isWinner ? .green : .red, flipped: alignment == .trailing)

            Text("CP \(power)")
                .font(.caption.weight(.bold))
                .foregroundStyle(color)
        }
        .frame(maxWidth: .infinity)
    }

    private var battleLogPanel: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Battle log", systemImage: "text.book.closed.fill")
                .font(.caption.weight(.bold))
                .foregroundStyle(.white.opacity(0.7))

            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(battle.turnLog) { turn in
                        BattleTurnRow(turn: turn, speciesA: battle.playerASpeciesId, speciesB: battle.playerBSpeciesId)
                    }
                }
            }
            .frame(maxHeight: 160)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.black.opacity(0.35))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
                )
        )
        .padding(12)
    }
}

struct BattleHPBar: View {
    let current: Int
    let maxHp: Int
    let tint: Color
    var flipped: Bool = false

    private var fraction: CGFloat {
        guard maxHp > 0 else { return 0 }
        return min(1, CGFloat(current) / CGFloat(maxHp))
    }

    var body: some View {
        VStack(alignment: flipped ? .trailing : .leading, spacing: 3) {
            Text("HP \(current)/\(maxHp)")
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundStyle(.white.opacity(0.75))
            GeometryReader { geo in
                ZStack(alignment: flipped ? .trailing : .leading) {
                    Capsule().fill(Color.white.opacity(0.15))
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [tint.opacity(0.7), tint],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: Swift.max(4, geo.size.width * fraction))
                }
            }
            .frame(height: 10)
        }
    }
}

struct BattleTurnRow: View {
    let turn: BattleTurn
    let speciesA: String
    let speciesB: String

    private var actorName: String {
        let speciesId = turn.actor == "a" ? speciesA : speciesB
        return CreatureCatalog.creature(withSpeciesId: speciesId)?.name ?? speciesId
    }

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("\(turn.turn)")
                .font(.caption2.weight(.black))
                .foregroundStyle(.yellow)
                .frame(width: 18)

            VStack(alignment: .leading, spacing: 2) {
                Text(turn.message.isEmpty ? "\(actorName) used \(turn.action)!" : turn.message)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.92))
                if turn.damage > 0 {
                    Text("−\(turn.damage) HP")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(.orange)
                }
            }
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white.opacity(turn.turn.isMultiple(of: 2) ? 0.06 : 0.03))
        )
    }
}

struct BattleHistoryRow: View {
    let battle: BattleRecord
    let headline: String

    var body: some View {
        HStack(spacing: 12) {
            miniSprite(battle.playerASpeciesId)
            Text("vs")
                .font(.caption.weight(.bold))
                .foregroundStyle(.secondary)
            miniSprite(battle.playerBSpeciesId)
            Spacer()
            Text(headline)
                .font(.caption.weight(.bold))
                .foregroundStyle(OutcomeStyle(headline: headline).solidColor)
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
        )
    }

    @ViewBuilder
    private func miniSprite(_ speciesId: String) -> some View {
        if let creature = CreatureCatalog.creature(withSpeciesId: speciesId) {
            CreatureStageVisualView(
                creature: creature,
                stage: .adult,
                compact: true,
                fixedVisualSize: 36
            )
        }
    }
}

// MARK: - Helpers

enum BattleSideHelper {
    static func side(for userId: String?, in battle: BattleRecord) -> String? {
        guard let userId else { return nil }
        if battle.playerAUserId == userId { return "a" }
        if battle.playerBUserId == userId { return "b" }
        return nil
    }
}

private struct OutcomeStyle {
    let headline: String

    var isWin: Bool { headline.localizedCaseInsensitiveContains("you win") }
    var isLoss: Bool { headline.localizedCaseInsensitiveContains("you lose") }

    var borderColor: Color {
        if isWin { return .green }
        if isLoss { return .red }
        return .yellow
    }

    var solidColor: Color { borderColor }

    var textGradient: LinearGradient {
        if isWin {
            return LinearGradient(colors: [.green, .mint], startPoint: .leading, endPoint: .trailing)
        }
        if isLoss {
            return LinearGradient(colors: [.orange, .red], startPoint: .leading, endPoint: .trailing)
        }
        return LinearGradient(colors: [.yellow, .white], startPoint: .leading, endPoint: .trailing)
    }
}
