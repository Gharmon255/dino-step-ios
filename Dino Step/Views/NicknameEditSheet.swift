//
//  NicknameEditSheet.swift
//  Dino Step
//

import SwiftUI

struct NicknameEditSheet: View {
    let title: String
    let speciesName: String
    let initialNickname: String?
    let onSave: (String?) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var nickname: String

    init(
        title: String,
        speciesName: String,
        initialNickname: String?,
        onSave: @escaping (String?) -> Void
    ) {
        self.title = title
        self.speciesName = speciesName
        self.initialNickname = initialNickname
        self.onSave = onSave
        _nickname = State(initialValue: initialNickname ?? "")
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Species") {
                    Text(speciesName)
                }

                Section("Nickname") {
                    TextField("Nickname (optional)", text: $nickname)
                        .textInputAutocapitalization(.words)
                        .onChange(of: nickname) { _, newValue in
                            if newValue.count > CreatureNickname.maxLength {
                                nickname = String(newValue.prefix(CreatureNickname.maxLength))
                            }
                        }

                    Text("\(nickname.count)/\(CreatureNickname.maxLength)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(CreatureNickname.normalize(nickname))
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
}
