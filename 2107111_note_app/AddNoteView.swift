//
//  AddNoteView.swift
//  2107083_note_app
//
//  Created by macos on 21/2/26.
//

import SwiftUI

struct AddNoteView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var firestoreManager: FirestoreManager

    // If note is provided => Edit mode
    var existingNote: Note?

    @State private var title: String
    @State private var content: String
    @FocusState private var focusField: Field?

    enum Field { case title, content }

    init(firestoreManager: FirestoreManager, existingNote: Note? = nil) {
        self.firestoreManager = firestoreManager
        self.existingNote = existingNote
        _title = State(initialValue: existingNote?.title ?? "")
        _content = State(initialValue: existingNote?.content ?? "")
    }

    private var isValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 14) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Title")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        TextField("e.g. Grocery list", text: $title)
                            .textFieldStyle(.roundedBorder)
                            .focused($focusField, equals: .title)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Content")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        TextEditor(text: $content)
                            .frame(minHeight: 220)
                            .padding(10)
                            .background(Color(.secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .focused($focusField, equals: .content)
                    }

                    Spacer(minLength: 0)
                }
                .padding()
            }
            .navigationTitle(existingNote == nil ? "New Note" : "Edit Note")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(existingNote == nil ? "Save" : "Update") {
                        if var note = existingNote {
                            note.title = title
                            note.content = content
                            firestoreManager.updateNote(note)
                        } else {
                            firestoreManager.addNote(title: title, content: content)
                        }
                        dismiss()
                    }
                    .disabled(!isValid)
                }
            }
            .onAppear { focusField = .title }
        }
    }
}
