//
//  ContentView.swift
//  Pantry
//
//  Created by nabbit on 01/11/2023.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var itemStore: ItemStore
    @EnvironmentObject var noteStore: NoteStore
    @State var editMode: EditMode = .inactive
    @State var selectedItems: Set<Item> = []
    @State var selectedNotes: Set<Note> = []
    @State private var isNewItemPopoverPresented: Bool = false
    @State private var isNewNotePopoverPresented: Bool = false
    @State var isSettingsPopoverPresented: Bool = false
    @State var canEditEmojis: Bool = false
    @State var canShowPinnedNotes: Bool = false
    @State private var canEditItem: Bool = false
    @State private var canEditNote: Bool = false
    @State private var confirmDeletion: Bool = false
    @State private var activeTabSelection: Int = 0
    @State private var previousTabSelection: Int = 0
    
    private let itemFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
        
    var body: some View {
        TabView(selection: $activeTabSelection) {
            NavigationView {
                List(selection: $selectedItems) {
                    ForEach(self.itemStore.items, id: \.self) { item in
                        //MARK: Item Information
                        NavigationLink {
                            ItemDetailsView(item: item, canEditItem: $canEditItem)
                            .navigationBarItems(
                                trailing:
                                    Button(action: {
                                        self.canEditItem.toggle()
                                    }) {
                                        Label("Edit Notes", systemImage: "applepencil.and.scribble")
                                    }
                            )
                            .navigationTitle("Item Details")
                            .navigationBarTitleDisplayMode(.inline)
                            .foregroundStyle(setFontColor(colorScheme: colorScheme), .blue)
                            .onDisappear(perform: {
                                self.selectedItems.removeAll()
                            })
                        } label: {
                            //MARK: Item List
                            ItemRowView(item: item, canEditEmojis: self.canEditEmojis)
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button("Delete", role: .destructive) {
                                let feedbackGenerator: UINotificationFeedbackGenerator? = UINotificationFeedbackGenerator()
                                feedbackGenerator?.notificationOccurred(.success)
                                self.itemStore.deleteEntry(entry: item)
                                self.selectedItems.removeAll()
                            }
                        }
                    }
                    .onMove(perform: { indices, newOffset in
                        self.itemStore.moveEntry(from: indices, to: newOffset)
                    })
                }
                .navigationTitle("Items")
                .navigationBarItems(
                    leading:
                        HStack {
                            if self.editMode == .inactive {
                                EmojiEditLockButton(canEditEmojis: $canEditEmojis)
                                    .foregroundStyle(setFontColor(colorScheme: colorScheme), self.canEditEmojis ? .green : .red)
#if DEBUG
                                ItemDebugButtons()
#endif
                            }
                            if self.editMode == .active {
                                SelectAllItemsButton(selectedItems: $selectedItems)
                                    .foregroundStyle(.blue, setFontColor(colorScheme: colorScheme))
                                    .disabled(editMode == .inactive ? true : false)
                                ItemDeleteButton(selectedItems: $selectedItems, confirmDeletion: $confirmDeletion)
                                    .foregroundStyle(self.selectedItems.isEmpty ? .gray : .red, .blue)
                                    .disabled(self.selectedItems.isEmpty)
                            }
                        },
                    trailing:
                        HStack {
                            EditModeButton(editMode: $editMode, selectedItems: $selectedItems, selectedNotes: $selectedNotes)
                            SettingsButton
                        }
                )
                .environment(\.editMode, $editMode)
                .foregroundStyle(setFontColor(colorScheme: colorScheme), .blue)
                .onAppear(perform: {
                    self.previousTabSelection = 0

                })
                .onDisappear(perform: {
                    self.editMode = .inactive
                })
                .refreshable {
                    self.itemStore.fetchEntries()
                }
                .alert(isPresented: $confirmDeletion) {
                    Alert(title: Text("Confirm Deletion"),
                          message:Text(deletionAlertText(selection: self.selectedItems.count)),
                          primaryButton: .cancel() {
                        self.selectedItems.removeAll()
                        self.editMode = .inactive
                        self.confirmDeletion = false
                    },
                          secondaryButton: .destructive(Text("Delete")) {
                        let feedbackGenerator: UINotificationFeedbackGenerator? = UINotificationFeedbackGenerator()
                        feedbackGenerator?.notificationOccurred(.success)
                        self.itemStore.deleteEntries(selection: self.selectedItems)
                        self.selectedItems.removeAll()
                        self.editMode = .inactive
                        self.confirmDeletion = false
                    })
                }
            }
            .tabItem {
                Image(systemName: "cart")
                Text("Items")
            }
            .popover(isPresented: $isNewItemPopoverPresented, attachmentAnchor: .point(.bottom), arrowEdge: .top) {
                NewItemView()
                    .padding()
                    .presentationCompactAdaptation(.popover)
            }
            .tag(0)
            NavigationView {
                List {

                }
                .navigationTitle("Change")
                .onAppear(perform: {
                    self.editMode = .inactive
                    if self.previousTabSelection == 0 {
                        self.activeTabSelection = 0
                        self.isNewItemPopoverPresented = true
                    } else if self.previousTabSelection == 2 {
                        self.activeTabSelection = 2
                        self.isNewNotePopoverPresented = true
                    }
                })
            }
            .tabItem {
                Image(systemName: getCurrentTabIcon(activeTab: self.activeTabSelection))
                Text(getCurrentTabName(activeTab: self.activeTabSelection))
            }
            .tag(1)
            NavigationView {
                List(selection: $selectedNotes) {
                    ForEach(self.noteStore.notes.filter{ self.canShowPinnedNotes ? $0.isPinned : true}, id: \.self) { note in
                        //MARK: Note Information
                        NavigationLink {
                            NoteDetailsView(note: note, canEditNote: $canEditNote)
                            .navigationBarItems(
                                trailing:
                                    Button(action: {
                                        self.canEditNote.toggle()
                                    }) {
                                        Label("Edit Notes", systemImage: "applepencil.and.scribble")
                                    }
                            )
                            .navigationTitle("Note Details")
                            .navigationBarTitleDisplayMode(.inline)
                            .foregroundStyle(setFontColor(colorScheme: colorScheme), .blue)
                            .onDisappear(perform: {
                                self.selectedNotes.removeAll()
                            })
                        } label: {
                            //MARK: Note List
                            NoteRowView(note: Binding(get: {note}, set: {_ in}))
                        }
                        .swipeActions(edge: .leading, allowsFullSwipe: true) {
                            Button("Pin") {
                                let selectionFeedback = UISelectionFeedbackGenerator()
                                selectionFeedback.selectionChanged()
                                self.noteStore.updatePin(entry: note)
                                self.selectedNotes.removeAll()
                            }
                            .tint(.orange)
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button("Delete", role: .destructive) {
                                let feedbackGenerator: UINotificationFeedbackGenerator? = UINotificationFeedbackGenerator()
                                feedbackGenerator?.notificationOccurred(.success)
                                self.noteStore.deleteEntry(entry: note)
                                self.selectedNotes.removeAll()
                            }
                        }
                    }
                    .onMove(perform: { indices, newOffset in
                        self.noteStore.moveEntry(from: indices, to: newOffset)
                    })
                }
                .navigationTitle("Notes")
                .navigationBarItems(
                    leading:
                        HStack {
                            if self.editMode == .inactive {
                                PinnedNotesButton(canShowPinnedNotes: $canShowPinnedNotes)
                                    .foregroundStyle(.orange, .orange)
#if DEBUG
                               NoteDebugButtons()
#endif
                            }
                            if self.editMode == .active {
                                SelectAllNotesButton(selectedNotes: $selectedNotes)
                                    .foregroundStyle(.blue, setFontColor(colorScheme: colorScheme))
                                    .disabled(editMode == .inactive ? true : false)
                                NoteDeleteButton(selectedNotes: $selectedNotes, confirmDeletion: $confirmDeletion)
                                    .foregroundStyle(self.selectedNotes.isEmpty ? .gray : .red, .blue)
                                    .disabled(self.selectedNotes.isEmpty)
                            }
                        },
                    trailing:
                        HStack {
                            EditModeButton(editMode: $editMode, selectedItems: $selectedItems, selectedNotes: $selectedNotes)
                            SettingsButton
                        }
                )
                .environment(\.editMode, $editMode)
                .foregroundStyle(setFontColor(colorScheme: colorScheme), .blue)
                .onAppear(perform: {
                    self.previousTabSelection = 2
                })
                .onDisappear(perform: {
                    self.editMode = .inactive
                })
                .refreshable {
                    self.noteStore.fetchEntries()
                }
                .alert(isPresented: $confirmDeletion) {
                    Alert(title: Text("Confirm Deletion"),
                          message:Text(deletionAlertText(selection: self.selectedNotes.count)),
                          primaryButton: .cancel() {
                        self.selectedNotes.removeAll()
                        self.editMode = .inactive
                        self.confirmDeletion = false
                    },
                          secondaryButton: .destructive(Text("Delete")) {
                        let feedbackGenerator: UINotificationFeedbackGenerator? = UINotificationFeedbackGenerator()
                        feedbackGenerator?.notificationOccurred(.success)
                        self.noteStore.deleteEntries(selection: self.selectedNotes)
                        self.selectedNotes.removeAll()
                        self.editMode = .inactive
                        self.confirmDeletion = false
                    })
                }
            }
            .tabItem {
                Image(systemName: "note.text")
                Text("Notes")
            }
            .popover(isPresented: $isNewNotePopoverPresented, attachmentAnchor: .point(.bottom), arrowEdge: .top) {
                NewNoteView()
                    .padding()
                    .presentationCompactAdaptation(.popover)
            }
            .tag(2)
        }
        .popover(isPresented: $isSettingsPopoverPresented) {
            SettingsView()
                .presentationCompactAdaptation(.fullScreenCover)
        }
        .onChange(of: self.editMode) { newValue in
            self.canEditEmojis = false
            self.canShowPinnedNotes = false
        }
        // This fixes navigationBarTitle LayoutConstraints issue for NavigationView
        .navigationViewStyle(.stack)
    }
}
        

private func deletionAlertText(selection: Int) -> String {
    let feedbackGenerator: UINotificationFeedbackGenerator? = UINotificationFeedbackGenerator()
    feedbackGenerator?.notificationOccurred(.warning)
    if selection == 1 {
        return "Are you sure you want to delete \(selection) Entry?"
    } else {
        return "Are you sure you want to delete \(selection) Entries?"
    }
}

private func getCurrentTabName(activeTab: Int) -> String {
    if activeTab == 0 {
        return "Add Item"
    } else if activeTab == 2 {
        return "Add Note"
    } else {
        return ""
    }
}

private func getCurrentTabIcon(activeTab: Int) -> String {
    if activeTab == 0 {
        return "cart.badge.plus"
    } else if activeTab == 2 {
        return "note.text.badge.plus"
    } else {
        return ""
    }
}

func setFontColor(colorScheme: ColorScheme) -> Color {
    return colorScheme == .light ? .black : .white
}

#Preview {
    ContentView()
        .environmentObject(ItemStore())
        .environmentObject(NoteStore())
        .preferredColorScheme(.light)
}

#Preview {
    ContentView()
        .environmentObject(ItemStore())
        .environmentObject(NoteStore())
        .preferredColorScheme(.dark)
}

