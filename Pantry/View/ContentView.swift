//
//  ContentView.swift
//  Pantry
//
//  Created by nabbit on 01/11/2023.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @EnvironmentObject var itemStore: ItemStore
    @EnvironmentObject var noteStore: NoteStore
    @Environment(\.colorScheme) var colorScheme
    @State private var isNewItemPopoverPresented: Bool = false
    @State private var isNewNotePopoverPresented: Bool = false
    @State private var isSettingsPopoverPresented: Bool = false
    @State private var canEditEmojis: Bool = false
    @State private var canEditItem: Bool = false
    @State private var canEditNote: Bool = false
    @State private var canShowPinnedNotes: Bool = false
    @State private var activeTabSelection = 0
    @State private var previousTabSelection = 0
        
    var body: some View {
        TabView(selection: $activeTabSelection) {
            NavigationView {
                List {
                    ForEach(itemStore.items, id: \.self) { item in
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
                            ItemRowView(item: item, canEditEmojis: canEditEmojis)
                        }
                    }
                    .onDelete(perform: { indexSet in
                        itemStore.deleteEntry(offsets: indexSet)
                    })
                }
                .navigationTitle("Lists")
                .navigationBarItems(
                    leading:
                        HStack {
                            Button(action: {
                                self.canEditEmojis.toggle()
                            }) {
                                Label("Lock Emojis", systemImage: canEditEmojis ? "hand.tap" : "hand.tap")
                                    .foregroundStyle(setFontColor(colorScheme: colorScheme), canEditEmojis ? .green : .red)
                            }
#if DEBUG
                            Button(action: {
                                itemStore.sampleItems()
                            }) {
                                Label("Mock Data", systemImage: "plus.circle.fill")
                                    .foregroundStyle(.white, .green)
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
                    self.previousTabSelection = 0

                })
                .refreshable {
                    itemStore.fetchEntries()
                }
            }
            .tabItem {
                Image(systemName: "cart")
                Text("List")
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
                        if previousTabSelection == 0 {
                            self.activeTabSelection = 0
                            self.isNewItemPopoverPresented = true
                        } else if previousTabSelection == 2 {
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
                List {
                    ForEach(noteStore.notes.filter{ self.canShowPinnedNotes ? $0.isPinned : true}, id: \.self) { note in
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
                        noteStore.deleteEntry(offsets: indexSet)
                    })
                }
                .navigationTitle("Notes")
                .navigationBarItems(
                    leading:
                        HStack {
                            Button(action: {
                                self.canShowPinnedNotes.toggle()
                            }) {
                                Label("Pinned Notes", systemImage: canShowPinnedNotes ? "pin.fill" : "pin")
                                    .foregroundStyle(.orange, .orange)
                            }
#if DEBUG
                            Button(action: {
                                noteStore.samepleNotes()
                            }) {
                                Label("Mock Data", systemImage: "plus.circle.fill")
                                    .foregroundStyle(.white, .green)
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
                    noteStore.fetchEntries()
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
