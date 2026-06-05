//
//  PrivacyPolicyLink.swift
//  Dino Step
//

import SwiftUI

struct PrivacyPolicyLink: View {
    var label: String = "Privacy Policy"

    var body: some View {
        Link(label, destination: LegalURLs.privacyPolicy)
            .font(.subheadline.weight(.semibold))
    }
}
