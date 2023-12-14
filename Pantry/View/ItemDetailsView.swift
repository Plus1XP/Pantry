//
//  ItemDetailsView.swift
//  Pantry
//
//  Created by nabbit on 09/11/2023.
//

import SwiftUI

struct ItemDetailsView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var itemStore: ItemStore
    @State var item: Item
    @Binding var canEditItem: Bool
    
    private let sectionTitleColor: Color = Color.secondary
    
    private let itemFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()

    var body: some View {
        VStack {
            //FIXME: EmojionField icon size
            HStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, content: {
                if self.canEditItem {
                    EmojiTextField(text: Binding(get: {item.name ?? ""}, set: {item.name = $0}))
                        .fixedSize(horizontal: true, vertical: true)
                } else {
                    Text(item.name ?? "")
                        .frame(maxWidth: .infinity)
                        .font(.system(size: 50))
                        .multilineTextAlignment(.center)
                }
            })
            .padding(.bottom)
            
            HStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, content: {
                Text("Quantity Remaining")
                    .font(.footnote)
                    .textCase(nil)
                    .foregroundStyle(self.sectionTitleColor)
            })
            HStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, content: {
                TextField("Quantity", text: Binding(get: {"\(item.quantity)"}, set: {item.quantity = Int64($0) ?? 0}))
                    .multilineTextAlignment(.trailing)
                    .disabled(!self.canEditItem)
                Text("of")
                TextField("Total", text: Binding(get: {"\(item.total)"}, set: {item.total = Int64($0) ?? 0}))
                    .multilineTextAlignment(.leading)
                    .disabled(!self.canEditItem)
            }) 
            .padding()
            .frame(maxWidth: .infinity)
            .foregroundColor(.primary)
            .background(
                RoundedRectangle(
                    cornerRadius: 12,
                    style: .continuous
                )
                .fill(setFieldBackgroundColor(colorScheme: self.colorScheme))
            )
            .padding(.leading)
            .padding(.trailing)
            .padding(.bottom)
            
            HStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, content: {
                Text("Notes")
                    .font(.footnote)
                    .textCase(nil)
                    .foregroundStyle(self.sectionTitleColor)
            })
            HStack(content: {
                if self.canEditItem {
                    TextEditor(text: Binding(get: {item.notes ?? ""}, set: {item.notes = $0}))
                        .scrollContentBackground(.hidden) // <- Hide it
                        .background(.clear) // To see this
                } else {
                    ScrollView { // <-- add scroll around Text
                        Text(item.notes ?? "")
                            .lineLimit(nil) // <-- tell Text to use as many lines as it needs (so no truncating)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading) // <-- tell Text to take the entire space available for ScrollView
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity) // <-- if needed, tell ScrollView to use the full size of its parent too
                }
            })
            .padding()
            .foregroundColor(.primary)
            .background(
                RoundedRectangle(
                    cornerRadius: 12,
                    style: .continuous
                )
                .fill(setFieldBackgroundColor(colorScheme: self.colorScheme))
            )
            .padding(.leading)
            .padding(.trailing)
            .padding(.bottom)
            
            if !self.canEditItem {
                HStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, content: {
                    Text("Last Modified")
                        .font(.footnote)
                        .textCase(nil)
                        .foregroundStyle(self.sectionTitleColor)
                })
                HStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, content: {
                    Text(item.modified!, formatter: self.itemFormatter)
                })
                .padding()
                .frame(maxWidth: .infinity)
                .foregroundColor(.primary)
                .background(
                    RoundedRectangle(
                        cornerRadius: 12,
                        style: .continuous
                    )
                    .fill(setFieldBackgroundColor(colorScheme: self.colorScheme))
                )
                .padding(.leading)
                .padding(.trailing)
                .padding(.bottom)
            }
            
            if self.canEditItem {
                HStack{
                    Spacer()
                    Button("Save", systemImage: "plus.circle", action: {
                        self.item.modified = Date()
                        self.itemStore.saveChanges()
                        self.canEditItem = false
                        self.dismiss()
                    })
                    .padding(.top)
                    .buttonStyle(.borderedProminent)
                    .tint(.green.opacity(0.9))
                    Spacer()
                    Button("Cancel", systemImage: "xmark.circle", action: {
                        self.itemStore.discardChanges()
                        self.canEditItem = false
                        self.dismiss()
                    })
                    .padding(.top)
                    .buttonStyle(.borderedProminent)
                    .tint(.red.opacity(0.9))
                    Spacer()
                }
                .foregroundStyle(.white, .white)
                .disabled(!self.canEditItem)
            }
        }
        .background(setViewBackgroundColor(colorScheme: self.colorScheme))
    }
}

private func setViewBackgroundColor(colorScheme: ColorScheme) -> Color {
    return colorScheme == .light ? Color.secondaryBackground : Color.background
}

private func setFieldBackgroundColor(colorScheme: ColorScheme) -> Color {
    return colorScheme == .light ? Color.background : Color.secondaryBackground
}

#Preview {
    ItemDetailsView(item: PersistenceController.shared.sampleItem, canEditItem: .constant(false))
        .environmentObject(ItemStore())
        .preferredColorScheme(.light)
}

#Preview {
    ItemDetailsView(item: PersistenceController.shared.sampleItem, canEditItem: .constant(false))
        .environmentObject(ItemStore())
        .preferredColorScheme(.dark)
}
