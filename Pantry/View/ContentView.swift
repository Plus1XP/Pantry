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
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.created, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>
    @State private var isNewItemPopoverPresented: Bool = false
    @State private var isEditNotesPopoverPresented: Bool = false
    @State private var canEditItems: Bool = false
    @State private var canEditNotes: Bool = false
    private var emojiSize: CGFloat = 15
    private var emojiSpacing: CGFloat?
    
    var body: some View {
        NavigationView {
            List {
                ForEach(items) { item in
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
                        .toolbar {
                            ToolbarItem(placement: .topBarTrailing) {
                                Button(action: {
                                    self.canEditNotes = !self.canEditNotes
                                    self.isEditNotesPopoverPresented = true
                                }) {
                                    Label("Edit Notes", systemImage: "pencil")
                                }
                                .popover(isPresented: $isEditNotesPopoverPresented) {
                                    EditNotesView(item: item)
                                        .environment(\.managedObjectContext, viewContext)
                                        .padding()
                                        .presentationCompactAdaptation(.sheet)
                                }
                            }
                        }
                    } label: {
                        HStack {
                            HStack(spacing: emojiSpacing) {
                                ForEach(0..<Int(item.total), id: \.self) { image in
                                    let emojiImage = item.name?.ToImage(fontSize: emojiSize)
                                    Image(uiImage: emojiImage!)
                                        .opacity(item.quantity >= Int64(image) ? 1.0 : 0.1)
                                        .onTapGesture {
                                            item.quantity = Int64(image)
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
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        self.canEditItems = !self.canEditItems
                    }) {
                        Label("Lock Items", systemImage: canEditItems ? "lock.open" : "lock")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: addItem) {
                        Label("Settings", systemImage: "gear")
                    }
                }
                ToolbarItemGroup(placement: .bottomBar) {
                    Spacer()
                    Button(action: {
                        self.isNewItemPopoverPresented = true
                    }) {
                        Label("Add Item", systemImage: "cart.badge.plus")
                    }
                    .popover(isPresented: $isNewItemPopoverPresented) {
                        NewItemView()
                            .environment(\.managedObjectContext, viewContext)
                            .padding()
                            .presentationCompactAdaptation(.popover)
                    }
                    Spacer()
                }
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
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    return formatter
}()

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
