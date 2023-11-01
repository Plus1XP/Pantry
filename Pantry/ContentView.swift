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
    
//    @State var refreshView: Bool = false
//    @Binding var rating: Int64
//    @Binding var canEditRating: Bool
//    var ratingEmoji: String
    @State private var isNewItemPopoverPresented: Bool = false
    @State private var canEditItems: Bool = false


    var ratingEmojiSize: CGFloat = 15
    var ratingEmojiSpacing: CGFloat?

    var body: some View {
        NavigationView {
            List {
                ForEach(items) { item in
//                    NavigationLink {
//                        Text("Item at \(item.timestamp!, formatter: itemFormatter)")
//                    } label: {
//                        Text(item.timestamp!, formatter: itemFormatter)
//                    }
                    NavigationLink {
                        Text("Modified at \(item.modified!, formatter: itemFormatter)")
                    } label: {
                        HStack {
//                            Text(item.name!)
                            HStack(spacing: ratingEmojiSpacing) {
                                ForEach(0..<Int(item.total)) { image in
                                    let emojiImage = item.name?.ToImage(fontSize: ratingEmojiSize)
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
//                                            NotificationCenter.default.post(name: Notification.Name("RefreshRatingView"), object: nil)
//                                            debugPrint("RatingView: RatingView Refreshed")
//                                            refreshView.toggle()
//                                            debugPrint("Rating has changed: \(rating + 1)")
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
#if os(iOS)
                ToolbarItem(placement: .topBarTrailing) {
                    EditButton()
                }
#endif
                ToolbarItemGroup(placement: .bottomBar) {
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
                    Button(action: addItem) {
                        Label("Settings", systemImage: "gear")
                    }
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

struct NewItemView: View {

    @Environment(\.dismiss) var dismiss
//    @Binding var selection: Emoji?

//    let columns = [GridItem(.adaptive(minimum: 44), spacing: 10)]
//    let emojis: [Emoji]  = Emoji.examples()
    @Environment(\.managedObjectContext) private var viewContext
//    @StateObject var context = ViewContext
    @State var name: String = ""
//    @State var quantity: Int64?
    @State var total: Int64 = 0

    var body: some View {
        VStack(alignment: .leading) {
            Text("Add an item")
                .font(.title3)
                .padding(.horizontal)

            Divider()
            
            Group {
                HStack {
                    Text("Name")
                    Spacer()
                    EmojiTextField(text: $name, placeholder: "Emoji of new item")
//                    TextField("Emoji of new item", text: $name)
                        .multilineTextAlignment(.trailing)
                        .disableAutocorrection(false)
                }
//                HStack {
//                    Text("Quantity")
//                    Spacer()
//                    TextField("Running total of new item", value: $quantity, formatter: NumberFormatter())
//                        .multilineTextAlignment(.trailing)
//                        .keyboardType(.decimalPad)
//                }
                HStack {
                    Text("Total")
                    Spacer()
                    TextField("Total of new item", value: $total, formatter: Formatter.myNumberFormat)
                        .multilineTextAlignment(.trailing)
                        .keyboardType(.decimalPad)
                }
            }
            
            Divider()
            
            HStack{
                Spacer()
                Button(action: {
                    let newItem = Item(context: viewContext)
                    newItem.id = UUID()
                    newItem.created = Date()
                    newItem.modified = Date()
                    newItem.name = self.name
                    newItem.quantity = self.total
                    newItem.total = self.total
                    
                    do {
                        try viewContext.save()
                    } catch {
                        // Replace this implementation with code to handle the error appropriately.
                        // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                        let nsError = error as NSError
                        fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                    }
                    dismiss()
                }) {
                    Label("Save Item", systemImage: "cart.badge.plus.fill")
                }
                .buttonStyle(GrowingButton())
                Spacer()
            }

            
                

//            ScrollView {
//                LazyVGrid(columns: columns) {
//                    ForEach(emojis) { emoji in
//                        ZStack {
//                            emoji == selection ? Color.blue : Color.clear
//                            Text(emoji.emojiSting)
//                                .font(.title)
//                                .padding(5)
//                                .onTapGesture {
//                                    selection = emoji
//                                    dismiss()
//                                }
//                        }
//                    }
//                }.padding()
//            }
        }
        .padding()
//        .environmentObject(context)
    }
}

struct GrowingButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(.blue)
            .foregroundStyle(.white)
            .clipShape(Capsule())
            .scaleEffect(configuration.isPressed ? 1.2 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .medium
    return formatter
}()

class UIEmojiTextField: UITextField {

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setEmoji() {
        _ = self.textInputMode
    }
    
    override var textInputContextIdentifier: String? {
           return ""
    }
    
    override var textInputMode: UITextInputMode? {
        for mode in UITextInputMode.activeInputModes {
            if mode.primaryLanguage == "emoji" {
                self.keyboardType = .default // do not remove this
                return mode
            }
        }
        return nil
    }
}

struct EmojiTextField: UIViewRepresentable {
    @Binding var text: String
    var placeholder: String = ""
    
    func makeUIView(context: Context) -> UIEmojiTextField {
        let emojiTextField = UIEmojiTextField()
        emojiTextField.placeholder = placeholder
        emojiTextField.text = text
        emojiTextField.delegate = context.coordinator
        return emojiTextField
    }
    
    func updateUIView(_ uiView: UIEmojiTextField, context: Context) {
        uiView.text = text
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: EmojiTextField
        
        init(parent: EmojiTextField) {
            self.parent = parent
        }
        
        func textFieldDidChangeSelection(_ textField: UITextField) {
            DispatchQueue.main.async { [weak self] in
                self?.parent.text = textField.text ?? ""
            }
        }
    }
}

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
