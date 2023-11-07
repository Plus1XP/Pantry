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
    @State private var isNewItemPopoverPresented: Bool = false
    @State private var isEditItemNotesPopoverPresented: Bool = false
    @State private var isNewNotePopoverPresented: Bool = false
    //    @State private var isEditNotesPopoverPresented: Bool = false
    @State private var isSettingsPopoverPresented: Bool = false
    @State private var canEditItems: Bool = false
    @State private var canEditItemNotes: Bool = false
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
                            List {
                                Section(header: Text("Item Information").frame(maxWidth: .infinity, alignment: .center)) {
                                    HStack {
                                        Text(item.name!)
                                            .frame(maxWidth: .infinity, alignment: .center)
                                    }
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
//                                HStack {
//                                    Button(action: {
//
//                                    }) {
//                                        Label("Back", systemImage: "arrowshape.turn.up.backward")
//                                            .foregroundStyle(.white, .white)
//                                            .frame(maxWidth: .infinity)
//                                    }
//                                    .buttonStyle(.borderedProminent)
//                                    .foregroundStyle(.white, .white)
//                                }
                            }
                            .navigationBarItems(
                                trailing:
                                    Button(action: {
                                        self.canEditItemNotes = !self.canEditItemNotes
                                        self.isEditItemNotesPopoverPresented = true
                                    }) {
                                        Label("Edit Notes", systemImage: "applepencil.and.scribble")
                                    }
                                    .popover(isPresented: $isEditItemNotesPopoverPresented) {
                                        EditNotesView(item: item)
                                            .environment(\.managedObjectContext, viewContext)
                                            .padding()
                                            .presentationCompactAdaptation(.sheet)
                                    }
                            )
                            .navigationTitle("Item Details")
//                            .navigationBarBackButtonHidden()
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
                    
                }
                .navigationTitle("Notes")
                .navigationBarItems(
                    leading:
                        HStack {
                            Button(action: {
                                self.canEditItems.toggle()
                            }) {
                                Label("Lock Items", systemImage: canEditItems ? "pin" : "pin.fill")
                                    .foregroundStyle(.orange, .orange)
                            }
                            Button(action: {
                                self.canEditItems.toggle()
                            }) {
                                Label("Lock Items", systemImage: canEditItems ? "bookmark" : "bookmark.fill")
                                    .foregroundStyle(.red, .red)
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
                Text("IT WORKS I HOPE")
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
