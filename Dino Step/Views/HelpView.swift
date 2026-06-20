//
//  HelpView.swift
//  Dino Step
//

import SwiftUI

struct HelpView: View {
    let includeEggsTab: Bool
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Everything in Stepasaurus")
                        .font(.headline)

                    ForEach(HelpTopics.sections(includeEggsTab: includeEggsTab)) { section in
                        GameCard {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(section.title)
                                    .font(.headline)
                                Text(section.body)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Help & tips")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    HelpView(includeEggsTab: false)
}
