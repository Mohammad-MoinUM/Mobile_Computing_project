//
//  NoteViewModel.swift
//  2107083_note_app
//
//  Created by macos on 21/2/26.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift

struct Note: Identifiable, Codable {
    @DocumentID var id: String?
    var title: String
    var content: String
    @ServerTimestamp var createdAt: Date?
}

final class FirestoreManager: ObservableObject {
    private let db = Firestore.firestore()
    @Published var notes: [Note] = []
    @Published var lastError: String? = nil

    private var listener: ListenerRegistration?

    private func notesRef() -> CollectionReference? {
        guard let uid = Auth.auth().currentUser?.uid else { return nil }
        return db.collection("users").document(uid).collection("notes")
    }

    func startListening() {
        guard let ref = notesRef() else {
            notes = []
            return
        }

        listener?.remove()
        listener = ref
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                if let error = error {
                    self?.lastError = error.localizedDescription
                    return
                }
                self?.notes = snapshot?.documents.compactMap { doc in
                    try? doc.data(as: Note.self)
                } ?? []
            }
    }

    func stopListening() {
        listener?.remove()
        listener = nil
        notes = []
    }

    func addNote(title: String, content: String) {
        guard let ref = notesRef() else { return }
        let newNote = Note(title: title, content: content)

        do {
            _ = try ref.addDocument(from: newNote)
        } catch {
            lastError = error.localizedDescription
        }
    }

    func updateNote(_ note: Note) {
        guard let ref = notesRef(), let id = note.id else { return }
        do {
            try ref.document(id).setData(from: note, merge: true)
        } catch {
            lastError = error.localizedDescription
        }
    }

    func deleteNote(_ note: Note) {
        guard let ref = notesRef(), let id = note.id else { return }
        ref.document(id).delete { [weak self] error in
            if let error = error {
                self?.lastError = error.localizedDescription
            }
        }
    }

    deinit { listener?.remove() }
}
