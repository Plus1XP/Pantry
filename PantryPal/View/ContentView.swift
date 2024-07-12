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
    @AppStorage("canEditEmojis") var canEditEmojis: Bool = true
    @State private var editMode: EditMode = .inactive
    @State private var isNewItemPopoverPresented: Bool = false
    @State private var isNewNotePopoverPresented: Bool = false
    @State private var isSettingsPopoverPresented: Bool = false
    @State private var isHideKeyboardButtonAcitve: Bool = false
    @State private var confirmItemDeletion: Bool = false
    @State private var confirmNoteDeletion: Bool = false
    @State private var confirmRestoreQuantity: Bool = false
    @State private var activeTabSelection: Int = 0
    @State private var previousTabSelection: Int = 0
    
    var body: some View {
//        let _ = Self._printChanges()
        TabView(selection: $activeTabSelection) {
            //MARK: Item TabView
            NavigationView {
                List(selection: $itemStore.itemSelection) {
                    ForEach(self.itemStore.searchResults, id: \.self) { item in
                        //MARK: Item Information
                        NavigationLink {
                            ItemDetailsView(isHideKeyboardButtonAcitve: $isHideKeyboardButtonAcitve, item: item)
                            .navigationBarItems(
                                trailing:
                                    Button(action: {
                                        withAnimation(.bouncy) {
                                            self.isHideKeyboardButtonAcitve = false
                                        }
                                    }) {
                                        Label("Edit Details", systemImage: "keyboard.chevron.compact.down")
                                            .symbolEffect(.bounce, value: self.isHideKeyboardButtonAcitve)
                                            .foregroundStyle(self.isHideKeyboardButtonAcitve ? .blue : .gray)
                                    }
                                    .disabled(!self.isHideKeyboardButtonAcitve)
                            )
                            .navigationTitle("Item Details")
                            .navigationBarTitleDisplayMode(.inline)
                            .foregroundStyle(setFontColor(colorScheme: colorScheme), .blue)
                            .onDisappear(perform: {
                                self.isHideKeyboardButtonAcitve = false
                                self.itemStore.itemSelection.removeAll()
                            })
                        } label: {
                            //MARK: Item List
                            ItemRowView(item: item)
                                .disabled(!canEditEmojis)
                        }
                        .swipeActions(edge: .leading, allowsFullSwipe: true) {
                            Button("Restore") {
                                let feedbackGenerator: UINotificationFeedbackGenerator? = UINotificationFeedbackGenerator()
                                feedbackGenerator?.notificationOccurred(.success)
                                self.itemStore.restoreQuantitySingleEntry(entry: item)
                            }
                            .tint(.green)
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button("Delete", role: .destructive) {
                                let feedbackGenerator: UINotificationFeedbackGenerator? = UINotificationFeedbackGenerator()
                                feedbackGenerator?.notificationOccurred(.success)
                                self.itemStore.deleteEntry(entry: item)
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
                                    .foregroundStyle(setFontColor(colorScheme: self.colorScheme), self.canEditEmojis ? .green : .red)
#if DEBUG
                                ItemDebugButtons()
#endif
                            }
                            if self.editMode == .active {
                                SelectAllItemsButton()
                                    .foregroundStyle(.blue, setFontColor(colorScheme: self.colorScheme))
                                    .disabled(self.editMode == .inactive ? true : false)
                                ItemDeleteButton(confirmDeletion: $confirmItemDeletion)
                                    .foregroundStyle(self.itemStore.itemSelection.isEmpty ? .gray : .red, .blue)
                                    .disabled(self.itemStore.itemSelection.isEmpty)
                                RestoreQuantityButton(confirmRestoreQuantity: $confirmRestoreQuantity)
                                    .foregroundStyle(self.itemStore.itemSelection.isEmpty ? .gray : self.confirmRestoreQuantity ? .white : .green, self.itemStore.itemSelection.isEmpty ? .gray : .green)
                                    .disabled(self.itemStore.itemSelection.isEmpty)
                            }
                        },
                    trailing:
                        HStack {
                            ItemUndoButton()
                            EditModeButton(editMode: $editMode)
                            SettingButton(canPresentSettingsPopOver: $isSettingsPopoverPresented)
                        }
                )
                .environment(\.editMode, $editMode)
                .foregroundStyle(setFontColor(colorScheme: self.colorScheme), .blue)
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
                .alert("Confirm Deletion", isPresented: $confirmItemDeletion) {
                    Button("Cancel", role: .cancel) {
                        self.itemStore.itemSelection.removeAll()
                        self.editMode = .inactive
                        self.confirmItemDeletion = false
                    }
                    Button("Delete", role: .destructive) {
                        let feedbackGenerator: UINotificationFeedbackGenerator? = UINotificationFeedbackGenerator()
                        feedbackGenerator?.notificationOccurred(.success)
                        self.itemStore.deleteItemSelectionEntries()
                        self.editMode = .inactive
                        self.confirmItemDeletion = false
                    }
                } message: {
                    Text(deletionAlertText(selection: self.itemStore.itemSelection.count))
                }
                .alert("Restore Item Quantity?", isPresented: $confirmRestoreQuantity) {
                    Button("Cancel", role: .cancel) {
                        self.itemStore.itemSelection.removeAll()
                        self.editMode = .inactive
                        self.confirmRestoreQuantity = false
                    }
                    Button("Restore Quantity", role: .destructive) {
                        let feedbackGenerator: UINotificationFeedbackGenerator? = UINotificationFeedbackGenerator()
                        feedbackGenerator?.notificationOccurred(.success)
                        self.itemStore.restoreQuantityItemSelectionEntries()
                        self.editMode = .inactive
                        self.confirmRestoreQuantity = false
                    }
                } message: {
                        Text(restoreQuantityAlertText(selection: self.itemStore.itemSelection.count))
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
                            NoteDetailsView(isHideKeyboardButtonAcitve: $isHideKeyboardButtonAcitve, note: note)
                            .navigationBarItems(
                                trailing:
                                    Button(action: {
                                        withAnimation(.bouncy) {
                                            self.isHideKeyboardButtonAcitve = false
                                        }
                                    }) {
                                        Label("Edit Details", systemImage: "keyboard.chevron.compact.down")
                                            .symbolEffect(.bounce, value: self.isHideKeyboardButtonAcitve)
                                            .foregroundStyle(self.isHideKeyboardButtonAcitve ? .blue : .gray)
                                    }
                                    .disabled(!self.isHideKeyboardButtonAcitve)
                            )
                            .navigationTitle("Note Details")
                            .navigationBarTitleDisplayMode(.inline)
                            .foregroundStyle(setFontColor(colorScheme: self.colorScheme), .blue)
                            .onDisappear(perform: {
                                self.isHideKeyboardButtonAcitve = false
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
                            }
                            .tint(.orange)
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button("Delete", role: .destructive) {
                                let feedbackGenerator: UINotificationFeedbackGenerator? = UINotificationFeedbackGenerator()
                                feedbackGenerator?.notificationOccurred(.success)
                                self.noteStore.deleteEntry(entry: note)
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
                                    .foregroundStyle(.blue, setFontColor(colorScheme: self.colorScheme))
                                    .disabled(self.editMode == .inactive ? true : false)
                                NoteDeleteButton( confirmDeletion: $confirmNoteDeletion)
                                    .foregroundStyle(self.noteStore.noteSelection.isEmpty ? .gray : .red, .blue)
                                    .disabled(self.noteStore.noteSelection.isEmpty)
                            }
                        },
                    trailing:
                        HStack {
                            NoteUndoButton()
                            EditModeButton(editMode: $editMode)
                            SettingButton(canPresentSettingsPopOver: $isSettingsPopoverPresented)
                        }
                )
                .environment(\.editMode, $editMode)
                .foregroundStyle(setFontColor(colorScheme: self.colorScheme), .blue)
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
                .alert("Confirm Deletion", isPresented: $confirmNoteDeletion) {
                    Button("Cancel", role: .cancel) {
                        self.noteStore.noteSelection.removeAll()
                        self.editMode = .inactive
                        self.confirmNoteDeletion = false
                    }
                    Button("Delete", role: .destructive) {
                        let feedbackGenerator: UINotificationFeedbackGenerator? = UINotificationFeedbackGenerator()
                        feedbackGenerator?.notificationOccurred(.success)
                        self.noteStore.deleteNoteSelectionEntries()
                        self.editMode = .inactive
                        self.confirmNoteDeletion = false
                    }
                } message: {
                    Text(deletionAlertText(selection: self.noteStore.noteSelection.count))
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
        .onChange(of: self.confirmItemDeletion, {
            let feedbackGenerator: UINotificationFeedbackGenerator? = UINotificationFeedbackGenerator()
            feedbackGenerator?.notificationOccurred(.warning)
        })
        .onChange(of: self.confirmNoteDeletion, {
            let feedbackGenerator: UINotificationFeedbackGenerator? = UINotificationFeedbackGenerator()
            feedbackGenerator?.notificationOccurred(.warning)
        })
        .onChange(of: self.confirmRestoreQuantity, {
            let feedbackGenerator: UINotificationFeedbackGenerator? = UINotificationFeedbackGenerator()
            feedbackGenerator?.notificationOccurred(.warning)
        })
        // This fixes navigationBarTitle LayoutConstraints issue for NavigationView
        .navigationViewStyle(.stack)
        .animation(.easeIn, value: self.editMode)
    }
}
        
//MARK: Functions
private func deletionAlertText(selection: Int) -> String {
    if selection == 1 {
        return "Are you sure you want to delete \(selection) Entry?"
    } else {
        return "Are you sure you want to delete \(selection) Entries?"
    }
}
                          
private func restoreQuantityAlertText(selection: Int) -> String {
    if selection == 1 {
        return "Are you sure you want to restore maximum quantity of \(selection) Entry?"
    } else {
        return "Are you sure you want to restore maximum quantities \(selection) Entries?"
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

