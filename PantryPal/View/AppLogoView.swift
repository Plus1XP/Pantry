//
//  AppLogoView.swift
//  PantryPal
//
//  Created by nabbit on 02/01/2024.
//

import SwiftUI

struct AppLogoView: View {
    @Binding var canShowAppLogo: Bool
    
    var body: some View {
        Image(uiImage: UIImage(named: "basket") ?? UIImage())
            .resizable()
            .scaledToFit()
            .padding()
        Button(action: {
            canShowAppLogo.toggle()
        }, label: {
            Image(systemName: "arrowshape.down.circle")
            Text("Download")
        })
        .buttonStyle(.borderedProminent)
        .foregroundColor(.white)
    }
}

#Preview {
    AppLogoView(canShowAppLogo: .constant(true))
}
