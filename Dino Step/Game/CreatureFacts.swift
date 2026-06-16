//
//  CreatureFacts.swift
//  Dino Step
//

import Foundation

enum CreatureFacts {
    static func forSpecies(_ speciesId: String) -> String {
        facts[speciesId] ?? "Paleontologists are still learning secrets about this dinosaur."
    }

    static func growthStageNote(creature: CreatureDefinition, stage: GrowthStage) -> String {
        switch stage {
        case .egg:
            return "Every \(creature.name) begins as a mystery egg — walk \(creature.hatchStep.formatted()) steps to hatch."
        case .baby:
            return "Freshly hatched! Baby \(creature.name) is small but full of energy."
        case .juvenile:
            return "At \(creature.juvenileStep.formatted()) steps, \(creature.name) hits a growth spurt as a juvenile."
        case .adult:
            return forSpecies(creature.speciesId)
        }
    }

    static func stepMilestoneLabel(creature: CreatureDefinition, stage: GrowthStage) -> String {
        switch stage {
        case .egg:
            return "\(creature.hatchStep.formatted()) steps to hatch"
        case .baby:
            return "From \(creature.hatchStep.formatted()) steps"
        case .juvenile:
            return "From \(creature.juvenileStep.formatted()) steps"
        case .adult:
            return "\(creature.totalStepsRequired.formatted()) steps total"
        }
    }

    private static let facts: [String: String] = [
        "tiny_raptor": "Small raptors were fast runners and may have hunted in groups.",
        "triceratops": "Triceratops had three horns and a huge frill to protect its neck.",
        "ankylosaurus": "Ankylosaurus wore bony armor and had a club on its tail.",
        "parasaurolophus": "Parasaurolophus had a hollow crest that may have made trumpet-like sounds.",
        "pachycephalosaurus": "Pachycephalosaurus had a thick dome skull used in head-butting displays.",
        "gallimimus": "Gallimimus looked like an ostrich and could run very fast on two legs.",
        "compsognathus": "Compsognathus was one of the smallest dinosaurs—about chicken size.",
        "stegosaurus": "Stegosaurus had diamond-shaped plates along its back and spiked tail.",
        "brachiosaurus": "Brachiosaurus held its neck high to reach treetops other dinos could not.",
        "pteranodon": "Pteranodon was a flying reptile, not a dinosaur—but it shared the skies with them.",
        "dilophosaurus": "Dilophosaurus had two thin crests on its head and lived in early Jurassic times.",
        "iguanodon": "Iguanodon had spiky thumbs and could walk on two legs or four.",
        "carnotaurus": "Carnotaurus had bull-like horns above its eyes and very short arms.",
        "baryonyx": "Baryonyx had long claws and fish hooks in its jaws—it loved catching fish.",
        "plesiosaurus": "Plesiosaurus had a long neck and paddles, swimming through ancient seas.",
        "trex": "T. rex had one of the strongest bites of any land animal ever.",
        "spinosaurus": "Spinosaurus is famous for the tall sail on its back and love of water.",
        "velociraptor_alpha": "Velociraptor was feathered and about the size of a turkey.",
        "allosaurus": "Allosaurus was a top predator of the Jurassic with sharp, curved teeth.",
        "therizinosaurus": "Therizinosaurus had enormous claws—longer than your arm.",
        "mosasaurus": "Mosasaurus was a giant sea reptile that ruled the oceans.",
        "diplodocus": "Diplodocus had one of the longest tails of any dinosaur.",
        "giganotosaurus": "Giganotosaurus rivaled T. rex in size and lived in South America.",
        "quetzalcoatlus": "Quetzalcoatlus was as tall as a giraffe when standing on the ground.",
        "indominus_hybrid": "This hybrid hunter blends traits of several fierce predators.",
        "ancient_spinosaurus": "Ancient Spinosaurus legends speak of a sail that glowed at dawn.",
        "crystal_ceratosaurus": "Crystal Ceratosaurus horns are said to shimmer like frozen starlight.",
        "volcanic_t_rex": "Volcanic T-Rex thrived near fiery peaks where ash enriched the jungle.",
        "frost_raptor": "Frost Raptors left claw marks in snow that never seemed to melt.",
        "shadow_triceratops": "Shadow Triceratops herds moved quietly through misty valleys at dusk.",
        "titanosaur": "Titanosaurs were among the largest animals to ever walk on land.",
        "cosmic_pterodactyl": "Cosmic Pterodactyls were said to ride warm winds above the clouds.",
        "ancient_apex_rex": "Ancient Apex Rex ruled its territory for generations.",
        "abyssal_mosasaurus": "Abyssal Mosasaurus hunted in the deepest, darkest waters.",
    ]
}
