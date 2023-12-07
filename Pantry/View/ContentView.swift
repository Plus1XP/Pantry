//
//  ContentView.swift
//  Pantry
//
//  Created by nabbit on 01/11/2023.
//

import SwiftUI

struct ContentView: View {
    //MARK: Variables
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var itemStore: ItemStore
    @EnvironmentObject private var noteStore: NoteStore
    @State private var editMode: EditMode = .inactive
    @State private var isNewItemPopoverPresented: Bool = false
    @State private var isNewNotePopoverPresented: Bool = false
    @State private var isSettingsPopoverPresented: Bool = false
    @State private var canEditEmojis: Bool = false
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
            //MARK: Item TabView
            NavigationView {
                List(selection: $itemStore.itemSelection) {
                    ForEach(self.itemStore.searchResults, id: \.self) { item in
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
                                self.canEditItem = false
                                self.itemStore.itemSelection.removeAll()
                            })
                        } label: {
                            //MARK: Item List
                            ItemRowView(item: item)
                                .disabled(!canEditEmojis)
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button("Delete", role: .destructive) {
                                let feedbackGenerator: UINotificationFeedbackGenerator? = UINotificationFeedbackGenerator()
                                feedbackGenerator?.notificationOccurred(.success)
                                self.itemStore.deleteEntry(entry: item)
                                self.itemStore.itemSelection.removeAll()
                            }
                        }
                    }
                    .onMove(perform: { indices, newOffset in
                        self.itemStore.moveEntry(from: indices, to: newOffset)
                    })
                }
                //MARK: Item Navigation
                .navigationTitle("Items")
                .navigationBarItems(
                    leading:
                        HStack {
                            if self.editMode == .inactive {
                                EmojiEditLockButton(canEditEmojis: $canEditEmojis)
                                    .foregroundStyle(setFontColor(colorScheme: colorScheme), self.canEditEmojis ? .green : .red)
#if DEBUG
//                                ItemDebugButtons()
#endif
                            }
                            if self.editMode == .active {
                                SelectAllItemsButton()
                                    .foregroundStyle(.blue, setFontColor(colorScheme: colorScheme))
                                    .disabled(editMode == .inactive ? true : false)
                                ItemDeleteButton(confirmDeletion: $confirmDeletion)
                                    .foregroundStyle(self.itemStore.itemSelection.isEmpty ? .gray : .red, .blue)
                                    .disabled(self.itemStore.itemSelection.isEmpty)
                            }
                        },
                    trailing:
                        HStack {
                            EditModeButton(editMode: $editMode)
                            SettingButton(canPresentSettingsPopOver: $isSettingsPopoverPresented)
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
                .searchable(text: $itemStore.searchText, prompt: "Search Items..")
                .alert(isPresented: $confirmDeletion) {
                    Alert(title: Text("Confirm Deletion"),
                          message:Text(deletionAlertText(selection: self.itemStore.itemSelection.count)),
                          primaryButton: .cancel() {
                        self.itemStore.itemSelection.removeAll()
                        self.editMode = .inactive
                        self.confirmDeletion = false
                    },
                          secondaryButton: .destructive(Text("Delete")) {
                        let feedbackGenerator: UINotificationFeedbackGenerator? = UINotificationFeedbackGenerator()
                        feedbackGenerator?.notificationOccurred(.success)
                        self.itemStore.deleteItemSelectionEntries()
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
            //MARK: AddEntry TabView
            NavigationView {
                List {

                }
                .navigationTitle("Add Entry")
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
            //MARK: Note TabView
            NavigationView {
                List(selection: $noteStore.noteSelection) {
                    ForEach(self.noteStore.combinedResults, id: \.self) { note in
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
                                self.canEditNote = false
                                self.noteStore.noteSelection.removeAll()
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
                                self.noteStore.noteSelection.removeAll()
                            }
                            .tint(.orange)
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button("Delete", role: .destructive) {
                                let feedbackGenerator: UINotificationFeedbackGenerator? = UINotificationFeedbackGenerator()
                                feedbackGenerator?.notificationOccurred(.success)
                                self.noteStore.deleteEntry(entry: note)
                                self.noteStore.noteSelection.removeAll()
                            }
                        }
                    }
                    .onMove(perform: { indices, newOffset in
                        self.noteStore.moveEntry(from: indices, to: newOffset)
                    })
                }
                //MARK: Note Navigation
                .navigationTitle("Notes")
                .navigationBarItems(
                    leading:
                        HStack {
                            if self.editMode == .inactive {
                                PinnedNotesButton()
                                    .foregroundStyle(.orange, .orange)
#if DEBUG
                               NoteDebugButtons()
#endif
                            }
                            if self.editMode == .active {
                                SelectAllNotesButton()
                                    .foregroundStyle(.blue, setFontColor(colorScheme: colorScheme))
                                    .disabled(editMode == .inactive ? true : false)
                                NoteDeleteButton( confirmDeletion: $confirmDeletion)
                                    .foregroundStyle(self.noteStore.noteSelection.isEmpty ? .gray : .red, .blue)
                                    .disabled(self.noteStore.noteSelection.isEmpty)
                            }
                        },
                    trailing:
                        HStack {
                            EditModeButton(editMode: $editMode)
                            SettingButton(canPresentSettingsPopOver: $isSettingsPopoverPresented)
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
                .searchable(text: $noteStore.searchText, prompt: "Search Notes..")
                .alert(isPresented: $confirmDeletion) {
                    Alert(title: Text("Confirm Deletion"),
                          message:Text(deletionAlertText(selection: self.noteStore.noteSelection.count)),
                          primaryButton: .cancel() {
                        self.noteStore.noteSelection.removeAll()
                        self.editMode = .inactive
                        self.confirmDeletion = false
                    },
                          secondaryButton: .destructive(Text("Delete")) {
                        let feedbackGenerator: UINotificationFeedbackGenerator? = UINotificationFeedbackGenerator()
                        feedbackGenerator?.notificationOccurred(.success)
                        self.noteStore.deleteNoteSelectionEntries()
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
        //MARK: Settings View
        .popover(isPresented: $isSettingsPopoverPresented) {
            SettingsView()
                .presentationCompactAdaptation(.fullScreenCover)
        }
        .onChange(of: self.editMode,
        {
            self.canEditEmojis = false
            self.noteStore.isPinnedNotesFiltered = false
        })
        // This fixes navigationBarTitle LayoutConstraints issue for NavigationView
        .navigationViewStyle(.stack)
    }
}
        
//MARK: Functions
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

//MARK: Previews
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

