//
//  CreatureDefinition.swift
//  Dino Step
//

import Foundation

struct CreatureDefinition: Identifiable, Equatable {
    let id: UUID
    /// Canonical slug aligned with Android (e.g. `tiny_raptor`, `pteranodon`).
    let speciesId: String
    let name: String
    let rarity: Rarity
    let habitat: Habitat
    let totalStepsRequired: Int
    let hatchStep: Int
    let juvenileStep: Int

    var isAssetBacked: Bool {
        CreatureCatalog.assetBackedSpeciesIds.contains(speciesId)
    }
}
