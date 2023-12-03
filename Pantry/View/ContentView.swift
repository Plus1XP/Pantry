//
//  ContentView.swift
//  Pantry
//
//  Created by nabbit on 01/11/2023.
//

import SwiftUI
//import CoreData

struct ContentView: View {
    @Environment(\.colorScheme) var colorScheme
//    @Environment(\.editMode) private var editMode
    @EnvironmentObject var itemStore: ItemStore
    @EnvironmentObject var noteStore: NoteStore
    @State private var editMode: EditMode = .inactive
    @State private var selectedItems: Set<Item> = []
    @State private var isNewItemPopoverPresented: Bool = false
    @State private var isNewNotePopoverPresented: Bool = false
    @State private var isSettingsPopoverPresented: Bool = false
    @State private var canEditEmojis: Bool = false
    @State private var canEditItem: Bool = false
    @State private var canEditNote: Bool = false
    @State private var canShowPinnedNotes: Bool = false
    @State private var activeTabSelection: Int = 0
    @State private var previousTabSelection: Int = 0
    @State private var confirmDeletion: Bool = false
    
    private var deleteAlertText: Text {
        if self.selectedItems.count == 1 {
            return Text("Are you sure you want to delete \(self.selectedItems.count) item?")
        } else {
            return Text("Are you sure you want to delete \(self.selectedItems.count) items?")
        }
    }
    
    private var canDisableTrashButton: Bool {
        if (self.editMode != .inactive && !self.selectedItems.isEmpty) {
            return false
        } else {
            return true
        }
    }
        
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
                        } label: {
                            //MARK: Item List
                            ItemRowView(item: item, canEditEmojis: self.canEditEmojis)
                        }
                    }
                    .onDelete(perform: { indexSet in
                        self.itemStore.deleteEntry(offsets: indexSet)
                    })
                    .onMove(perform: { indices, newOffset in
                        self.itemStore.moveEntry(from: indices, to: newOffset)
                    })
//                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
//                        Button("Delete", role: .destructive) {
//                            let feedbackGenerator: UINotificationFeedbackGenerator? = UINotificationFeedbackGenerator()
//                            feedbackGenerator?.notificationOccurred(.error)
//                            self.itemStore.deleteEntry(entry: Array(selectedItems))
//                            self.itemStore.fetchEntries()
//                            self.selectedItems.removeAll()
//                        }
//                    }
                }
                .navigationTitle("Items")
                .navigationBarItems(
                    leading:
//                        switch editMode {
//                               case .inactive:
//                                   return NewItemView()
//                               default:
//                                   return NewNoteView()
//                               }
                    
                        HStack {
                            if self.editMode == .inactive {
                                Button(action: {
                                    self.canEditEmojis.toggle()
                                }) {
                                    Label("Lock Emojis", systemImage: self.canEditEmojis ? "hand.tap" : "hand.tap")
                                        .foregroundStyle(setFontColor(colorScheme: colorScheme), self.canEditEmojis ? .green : .red)
                                }
    //                            EditButton()
    #if DEBUG
                                Button(action: {
                                    self.itemStore.sampleItems()
                                }) {
                                    Label("Mock Data", systemImage: "plus.circle.fill")
                                        .foregroundStyle(.white, .green)
                                }
                                Button(action: {
                                    self.itemStore.deleteAll()
                                }) {
                                    Label("Mock Data", systemImage: "minus.circle.fill")
                                        .foregroundStyle(.white, .red)
                                }
    #endif
                            }
                            if self.editMode == .active {
                                Button(action: {
                                    self.confirmDeletion = true
//                                    itemStore.deleteEntries(selection: selectedItems)
//                                    let feedbackGenerator: UINotificationFeedbackGenerator? = UINotificationFeedbackGenerator()
//                                    feedbackGenerator?.notificationOccurred(.error)
                                }) {
                                    Label("Trash", systemImage: "trash")
                                        .foregroundStyle(self.canDisableTrashButton ? .gray : .red, .blue)
                                }
                                .disabled(self.canDisableTrashButton)
                            }
                            
                        },
                    trailing:
                        HStack {
                            Button {
                                if self.editMode == .inactive {
                                    let feedbackGenerator: UINotificationFeedbackGenerator? = UINotificationFeedbackGenerator()
                                    feedbackGenerator?.notificationOccurred(.success)
                                    self.editMode = .active
                                }
                                else if self.editMode == .active {
                                    let feedbackGenerator: UINotificationFeedbackGenerator? = UINotificationFeedbackGenerator()
                                    feedbackGenerator?.notificationOccurred(.warning)
                                    self.selectedItems.removeAll()
                                    self.editMode = .inactive
                                }
                            } label: {
                                Image(systemName: self.editMode == .active ? "checklist.checked" : "checklist.unchecked")
                                    .foregroundStyle(setFontColor(colorScheme: colorScheme), setFontColor(colorScheme: colorScheme))
//                                Image(systemName: self.editMode == .active ? "list.bullet.circle.fill" : "list.bullet.circle")
//                                Text(editMode == .inactive ? "Edit" : "Done")
        //                            .padding(7)
        //                            .background(.thinMaterial)
        //                            .cornerRadius(10)
                            }
                        
//                            EditButton()
                            Button(action: {
                                self.isSettingsPopoverPresented.toggle()
                            }) {
                                Label("Settings", systemImage: "gear")
                            }
                        }
                )
                .environment(\.editMode, $editMode)
                .foregroundStyle(setFontColor(colorScheme: colorScheme), .blue)
                .onAppear(perform: {
                    self.previousTabSelection = 0

                })
                .refreshable {
                    self.itemStore.fetchEntries()
                }
                .alert(isPresented: $confirmDeletion) {
                    Alert(title: Text("Confirm Deletion"),
                          message: self.deleteAlertText,
                          primaryButton: .cancel() {
                        self.selectedItems.removeAll()
                        self.editMode = .inactive
                        self.confirmDeletion = false
                    },
                          secondaryButton: .destructive(Text("Delete")) {
                        let feedbackGenerator: UINotificationFeedbackGenerator? = UINotificationFeedbackGenerator()
                        feedbackGenerator?.notificationOccurred(.error)
                        self.itemStore.deleteEntries(selection: self.selectedItems)
//                        contactsViewModel.fetchContacts()
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
//                Image(systemName: self.editMode == .active ? "trash" :getCurrentTabIcon(activeTab: self.activeTabSelection))
//                Text(self.editMode == .active ? "Delete" : getCurrentTabName(activeTab: self.activeTabSelection))
            }
            .tag(1)
            NavigationView {
                List {
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
                        } label: {
                            //MARK: Note List
                            NoteRowView(note: Binding(get: {note}, set: {_ in}))
                        }
                    }
                    .onDelete(perform: { indexSet in
                        self.noteStore.deleteEntry(offsets: indexSet)
                    })
                    .onMove(perform: { indices, newOffset in
                        self.noteStore.moveEntry(from: indices, to: newOffset)
                    })
                }
                .navigationTitle("Notes")
                .navigationBarItems(
                    leading:
                        HStack {
                            Button(action: {
                                self.canShowPinnedNotes.toggle()
                            }) {
                                Label("Pinned Notes", systemImage: self.canShowPinnedNotes ? "pin.fill" : "pin")
                                    .foregroundStyle(.orange, .orange)
                            }
                            EditButton()
#if DEBUG
                            Button(action: {
                                self.noteStore.samepleNotes()
                            }) {
                                Label("Mock Data", systemImage: "plus.circle.fill")
                                    .foregroundStyle(.white, .green)
                            }
                            Button(action: {
                                self.noteStore.deleteAll()
                            }) {
                                Label("Mock Data", systemImage: "minus.circle.fill")
                                    .foregroundStyle(.white, .red)
                            }
#endif
                        },
                    trailing:
                        Button(action: {
                            self.isSettingsPopoverPresented.toggle()
                        }) {
                            Label("Settings", systemImage: "gear")
                        }
                )
                .foregroundStyle(setFontColor(colorScheme: colorScheme), .blue)
                .onAppear(perform: {
                    self.previousTabSelection = 2
                })
                .refreshable {
                    self.noteStore.fetchEntries()
                }
            }
            .tabItem {
                Image(systemName: "note.text")
                Text("Notes")
            }
//            .onChange(of: self.editMode) { value in
//                if editMode == .active {
//                  test.toggle()
//                  debugPrint(test.description)
//                    UITabBar.appearance().unselectedItemTintColor = UIColor.green
//                    
//              } else {
//                  test.toggle()
//                  debugPrint(test.description)
//              }
//            }
            .popover(isPresented: $isNewNotePopoverPresented, attachmentAnchor: .point(.bottom), arrowEdge: .top) {
                NewNoteView()
                    .padding()
                    .presentationCompactAdaptation(.popover)
            }
            .tag(2)
        }
//        .tint(self.editMode == .active ? .red : .blue)
        .popover(isPresented: $isSettingsPopoverPresented) {
            SettingsView()
                .presentationCompactAdaptation(.fullScreenCover)
        }
        // This fixes navigationBarTitle LayoutConstraints issue for NavigationView
        .navigationViewStyle(.stack)
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    return formatter
}()

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

//private func getEditModeIcon(editMode: EditMode) -> String {
//    if editMode == .active {
//        return "trash"
//    } else {
//        return "gear"
//    }
//}

private func setFontColor(colorScheme: ColorScheme) -> Color {
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
