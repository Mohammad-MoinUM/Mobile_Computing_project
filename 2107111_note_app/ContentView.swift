//
//  ContentView.swift
//  2107083_note_app
//
//  Created by macos on 21/2/26.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var firestoreManager = FirestoreManager()
    @EnvironmentObject var authViewModel: AuthViewModel

    @State private var searchText = ""
    @State private var showingEditor = false
    @State private var selectedNoteForEdit: Note? = nil
    @State private var notePendingDelete: Note? = nil
    @State private var showError = false

    private var filteredNotes: [Note] {
        let q = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !q.isEmpty else { return firestoreManager.notes }
        return firestoreManager.notes.filter {
            $0.title.lowercased().contains(q) || $0.content.lowercased().contains(q)
        }
    }

    var body: some View {
        NavigationView {
            ZStack(alignment: .bottomTrailing) {
                Group {
                    if filteredNotes.isEmpty {
                        emptyState
                    } else {
                        notesList
                    }
                }
                .padding(.top, 6)

                floatingAddButton
            }
            .navigationTitle("My Notes")
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .automatic))
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if let email = authViewModel.user?.email {
                        Text(email)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(role: .destructive) {
                            authViewModel.signOut()
                            firestoreManager.stopListening()
                        } label: {
                            Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                        }
                    } label: {
                        Image(systemName: "person.crop.circle")
                            .imageScale(.large)
                    }
                }
            }
            .onAppear {
                firestoreManager.startListening()
            }
            .onChange(of: authViewModel.isSignedIn) { signedIn in
                if signedIn {
                    firestoreManager.startListening()
                } else {
                    firestoreManager.stopListening()
                }
            }
            .onChange(of: firestoreManager.lastError) { err in
                showError = (err != nil)
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) { firestoreManager.lastError = nil }
            } message: {
                Text(firestoreManager.lastError ?? "Unknown error")
            }
            .alert("Delete note?", isPresented: Binding(
                get: { notePendingDelete != nil },
                set: { if !$0 { notePendingDelete = nil } }
            )) {
                Button("Delete", role: .destructive) {
                    if let n = notePendingDelete { firestoreManager.deleteNote(n) }
                    notePendingDelete = nil
                }
                Button("Cancel", role: .cancel) { notePendingDelete = nil }
            } message: {
                Text("This can’t be undone.")
            }
            .sheet(isPresented: $showingEditor, onDismiss: { selectedNoteForEdit = nil }) {
                AddNoteView(firestoreManager: firestoreManager, existingNote: selectedNoteForEdit)
            }
        }
    }

    private var notesList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(filteredNotes) { note in
                    NoteCardView(note: note)
                        .onTapGesture {
                            selectedNoteForEdit = note
                            showingEditor = true
                        }
                        .contextMenu {
                            Button {
                                selectedNoteForEdit = note
                                showingEditor = true
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }

                            Button(role: .destructive) {
                                notePendingDelete = note
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                notePendingDelete = note
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }

                            Button {
                                selectedNoteForEdit = note
                                showingEditor = true
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                            .tint(.blue)
                        }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 90) // space for floating button
        }
    }

    private var emptyState: some View {
        VStack(spacing: 10) {
            Image(systemName: "note.text")
                .font(.system(size: 44))
                .foregroundColor(.secondary)

            Text("No notes yet")
                .font(.title3)
                .fontWeight(.semibold)

            Text("Tap + to create your first note.")
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }

    private var floatingAddButton: some View {
        Button {
            selectedNoteForEdit = nil
            showingEditor = true
        } label: {
            Image(systemName: "plus")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 54, height: 54)
                .background(Color.accentColor)
                .clipShape(Circle())
                .shadow(radius: 8)
        }
        .padding(.trailing, 18)
        .padding(.bottom, 18)
        .accessibilityLabel("Add Note")
    }
}

private struct NoteCardView: View {
    let note: Note

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(note.title.isEmpty ? "(Untitled)" : note.title)
                .font(.headline)
                .lineLimit(1)

            Text(note.content)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color(.separator).opacity(0.25), lineWidth: 1)
        )
    }
}
