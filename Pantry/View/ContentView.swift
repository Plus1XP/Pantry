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
    @State private var canEditItems: Bool = false
    @State private var canEditItemNotes: Bool = false
    private var emojiSize: CGFloat = 15
    private var emojiSpacing: CGFloat?
    
    @State private var tabSelection = 0
    
    var body: some View {
        TabView(selection: $tabSelection) {
            NavigationView {
                List {
                    ForEach(items) { item in
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
                            }
                            .navigationBarItems(
                                trailing:
                                    Button(action: {
                                        self.canEditItemNotes = !self.canEditItemNotes
                                        self.isEditItemNotesPopoverPresented = true
                                    }) {
                                        Label("Edit Notes", systemImage: "pencil")
                                    }
                                    .popover(isPresented: $isEditItemNotesPopoverPresented) {
                                        EditNotesView(item: item)
                                            .environment(\.managedObjectContext, viewContext)
                                            .padding()
                                            .presentationCompactAdaptation(.sheet)
                                    }
                            )
                            .foregroundStyle(colorScheme == .light ? .gray : .white, .blue)
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
                }
                .foregroundStyle(colorScheme == .light ? .gray : .white, .blue)
                .navigationTitle("Lists")
                .navigationBarItems(
                    leading:
                        Button(action: {
                            self.canEditItems = !self.canEditItems
                        }) {
                            Label("Lock Items", systemImage: canEditItems ? "hand.tap.fill" : "hand.tap")
                                .foregroundStyle(colorScheme == .light ? .gray : .white, canEditItems ? .green : .red)
                        },
                    trailing:
                        Button(action: {
                            self.isNewItemPopoverPresented = true
                        }) {
                            Label("Add Item", systemImage: "cart.badge.plus")
                                .foregroundStyle(.green, colorScheme == .light ? .gray : .white)
                        }
                        .popover(isPresented: $isNewItemPopoverPresented) {
                            NewItemView()
                                .environment(\.managedObjectContext, viewContext)
                                .padding()
                                .presentationCompactAdaptation(.popover)
                        }
                )
            }
            .tabItem {
                Image(systemName: "list.bullet.rectangle")
                Text("List")
            }
            .tag(0)
            NavigationView {
                List {
                    
                }
                .foregroundStyle(colorScheme == .light ? .gray : .white, .blue)
                .navigationTitle("Notes")
                .navigationBarItems(
                    leading:
                        Button(action: {
                            self.canEditItems = !self.canEditItems
                            debugPrint(Color.background)
                        }) {
                            Label("Lock Items", systemImage: canEditItems ? "lock.open" : "lock")
                        },
                    trailing:
                        Button(action: {
                            self.isNewNotePopoverPresented = true
                        }) {
                            Label("Add Note", systemImage: "note.text.badge.plus")
                                .foregroundStyle(.green, colorScheme == .light ? .gray : .white)
                        }
                        .popover(isPresented: $isNewNotePopoverPresented) {
                            Text("TESTING PLS DONT CRASH")
                                .padding()
                                .presentationCompactAdaptation(.popover)
                        }
                )
            }
            .tabItem {
                Image(systemName: "note.text")
                Text("Notes")
            }
            .tag(1)
            NavigationView {
                SettingsView()
                    .navigationTitle("Settings")
            }
            .tabItem {
                Image(systemName: "gear")
                Text("Settings")
            }
            .tag(2)
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

func getItemQuantityWithOffset(quantity: Int64) -> Int64 {
    return quantity - 1
}

func setItemQuantityWithOffset(quantity: Int64) -> Int64 {
    return quantity + 1
}

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        .preferredColorScheme(.light)
}

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        .preferredColorScheme(.dark)
}
