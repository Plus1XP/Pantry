//
//  ContentView.swift
//  Pantry
//
//  Created by nabbit on 01/11/2023.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.colorScheme) var colorScheme
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.created, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Note.created, ascending: true)],
        animation: .default)
    private var notes: FetchedResults<Note>
    @State private var isNewItemPopoverPresented: Bool = false
    @State private var isEditItemNotesPopoverPresented: Bool = false
    @State private var isNewNotePopoverPresented: Bool = false
    @State private var isEditNotesPopoverPresented: Bool = false
    @State private var isSettingsPopoverPresented: Bool = false
    @State private var canEditItems: Bool = false
    @State private var canShowPinnedNotes: Bool = false
    private var emojiSize: CGFloat = 15
    private var emojiSpacing: CGFloat?
    
    @State private var activeTabSelection = 0
    @State private var previousTabSelection = 0
    
    var body: some View {
        TabView(selection: $activeTabSelection) {
            NavigationView {
                List {
                    ForEach(items, id: \.self) { item in
                        //MARK: Item Information
                        NavigationLink {
                            Form {
                                Section(header: Text(item.name!)
                                    .font(.largeTitle)
                                    .frame(maxWidth: .infinity, alignment: .center)) {
                                    
                                }
                                Section(header: Text("Quantity Remaining").frame(maxWidth: .infinity, alignment: .center)) {
                                    HStack {
                                        Text("\(item.quantity.description) / \(item.total.description)")
                                            .frame(maxWidth: .infinity, alignment: .center)
                                    }
                                }
                                Section(header: Text("Notes").frame(maxWidth: .infinity, alignment: .center)) {
                                    HStack {
                                        Text(item.notes ?? "")
                                            .frame(
                                                minWidth: 0,
                                                maxWidth: .infinity,
                                                minHeight: 0,
                                                maxHeight: .infinity,
                                                alignment: .center
                                            )
                                    }
                                }
                                Section(header: Text("Last Modified").frame(maxWidth: .infinity, alignment: .center)) {
                                    HStack {
                                        Text(item.modified!, formatter: itemFormatter)
                                            .frame(maxWidth: .infinity, alignment: .center)
                                    }
                                }
                            }
                            .navigationBarItems(
                                trailing:
                                    Button(action: {
                                        self.isEditItemNotesPopoverPresented = true
                                    }) {
                                        Label("Edit Notes", systemImage: "applepencil.and.scribble")
                                    }
                                    .popover(isPresented: $isEditItemNotesPopoverPresented) {
                                        EditItemView(item: item)
                                            .environment(\.managedObjectContext, viewContext)
                                            .padding()
                                            .presentationCompactAdaptation(.sheet)
                                    }
                            )
                            .navigationTitle("Item Details")
                            .navigationBarTitleDisplayMode(.inline)
                            .foregroundStyle(setFontColor(colorScheme: colorScheme), .blue)
                        } label: {
                            //MARK: Item List
                            HStack {
                                HStack(spacing: emojiSpacing) {
                                    ForEach(0..<Int(item.total), id: \.self) { image in
                                        let emojiImage = item.name?.ToImage(fontSize: emojiSize)
                                        Image(uiImage: emojiImage!)
                                            .opacity(getItemQuantityWithOffset(quantity: item.quantity) >= Int64(image) ? 1.0 : 0.1)
                                            .onTapGesture {
                                                item.quantity = setItemQuantityWithOffset(quantity: Int64(image))
                                                item.modified = Date()
                                                do {
                                                    try viewContext.save()
                                                } catch {
                                                    // Replace this implementation with code to handle the error appropriately.
                                                    // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                                                    let nsError = error as NSError
                                                    fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                                                }
                                            }
                                    }
                                }
                                .disabled(!canEditItems)
                            }
                        }
                    }
                    .onDelete(perform: deleteItems)
//                    .onMove { items.move(fromOffsets: $0, toOffset: $1) }
                }
                .navigationTitle("Lists")
                .navigationBarItems(
                    leading:
                        HStack {
                            Button(action: {
                                self.canEditItems = !self.canEditItems
                            }) {
                                Label("Lock Items", systemImage: canEditItems ? "hand.tap" : "hand.tap")
                                    .foregroundStyle(setFontColor(colorScheme: colorScheme), canEditItems ? .green : .red)
                            }
                        },
                    trailing:
                        Button(action: {
                            self.isSettingsPopoverPresented.toggle()
                        }) {
                            Label("Settings", systemImage: "gear")
                        }
//                        NavigationLink {
//                            SettingsView()
//                                .navigationTitle("Settings")
//                                .navigationBarBackButtonHidden()
//                        } label: {
//                            Label("Settings", systemImage: "gear")
//                        }
                )
                .foregroundStyle(setFontColor(colorScheme: colorScheme), .blue)
                .onAppear(perform: {
                    self.previousTabSelection = 0

                })
            }
            .tabItem {
                Image(systemName: "cart")
                Text("List")
            }
            .popover(isPresented: $isNewItemPopoverPresented, attachmentAnchor: .point(.bottom), arrowEdge: .top) {
                NewItemView()
                    .environment(\.managedObjectContext, viewContext)
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
                    ForEach(notes.filter{ self.canShowPinnedNotes ? $0.pinned : true}) { note in
                        //MARK: Note Information
                        NavigationLink {
                            Form {
                                Section {
                                    Text(note.body!)
                                        .frame(maxWidth: .infinity, alignment: .center)
                                } header: {
                                    Text(note.name!)
                                        .font(.title2)
                                        .frame(maxWidth: .infinity, alignment: .center)
                                } footer: {
                                    Text(Image(systemName: note.pinned ? "pin.fill" : "pin"))
                                        .padding()
                                        .font(.title3)
                                        .frame(maxWidth: .infinity, alignment: .center)
                                }
                                Section(header: Text("Last Modified").frame(maxWidth: .infinity, alignment: .center))
                                {
                                    Text(note.modified!, formatter: itemFormatter)
                                        .frame(maxWidth: .infinity, alignment: .center)
                                }
                            }
                            .navigationBarItems(
                                trailing:
                                    Button(action: {
                                        self.isEditNotesPopoverPresented = true
                                    }) {
                                        Label("Edit Notes", systemImage: "applepencil.and.scribble")
                                    }
                                    .popover(isPresented:
                                        $isEditNotesPopoverPresented) {
                                        EditNoteView(note: note)
                                            .environment(\.managedObjectContext, viewContext)
                                            .padding()
                                            .presentationCompactAdaptation(.sheet)
                                    }
                            )
                            .navigationTitle("Note Details")
                            .navigationBarTitleDisplayMode(.inline)
                            .foregroundStyle(setFontColor(colorScheme: colorScheme), .blue)
                        } label: {
                            //MARK: Note List
                            HStack {
                                Text(note.name!)
                                Spacer()
                                Text(Image(systemName: note.pinned ? "pin.fill" : "pin"))
                            }
                        }
                    }
                    .onDelete(perform: deleteNotes)
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
                        },
                    trailing:
                        Button(action: {
                            self.isSettingsPopoverPresented.toggle()
                        }) {
                            Label("Settings", systemImage: "gear")
                        }
//                        NavigationLink {
//                            SettingsView()
//                                .navigationTitle("Settings")
//                                .navigationBarBackButtonHidden()
//                        } label: {
//                            Label("Settings", systemImage: "gear")
//                        }
                )
                .foregroundStyle(setFontColor(colorScheme: colorScheme), .blue)
                .onAppear(perform: {
                    self.previousTabSelection = 2
                })
            }
            .tabItem {
                Image(systemName: "note.text")
                Text("Notes")
            }
            .popover(isPresented: $isNewNotePopoverPresented, attachmentAnchor: .point(.bottom), arrowEdge: .top) {
                NewNoteView()
                    .environment(\.managedObjectContext, viewContext)
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
    
    private func addNote() {
        withAnimation {
            let newNote = Note(context: viewContext)
            newNote.id = UUID()
            newNote.name = "my Secret"
            newNote.body = "Im really happy!"
            newNote.pinned = false
            newNote.created = Date()
            newNote.modified = Date()
            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    private func addItem() {
        withAnimation {
            let newItem = Item(context: viewContext)
            newItem.id = UUID()
            newItem.name = "🧅"
            newItem.quantity = 5
            newItem.total = 5
            newItem.created = Date()
            newItem.modified = Date()
            newItem.notes = "Some bullshit here"
            
            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)
            
            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    private func deleteNotes(offsets: IndexSet) {
        withAnimation {
            offsets.map { notes[$0] }.forEach(viewContext.delete)
            
            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    return formatter
}()

private func getItemQuantityWithOffset(quantity: Int64) -> Int64 {
    return quantity - 1
}

private func setItemQuantityWithOffset(quantity: Int64) -> Int64 {
    return quantity + 1
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

private func setFontColor(colorScheme: ColorScheme) -> Color {
    return colorScheme == .light ? .black : .white
}

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        .preferredColorScheme(.light)
}

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        .preferredColorScheme(.dark)
}
