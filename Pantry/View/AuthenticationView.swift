//
//  AuthenticationView\.swift
//  Pantry
//
//  Created by nabbit on 14/11/2023.
//

import SwiftUI
import CoreData

struct AuthenticationView: View {
    @EnvironmentObject var biometricStore: BiometricStore

    var body: some View {
        ZStack {
            if biometricStore.isFaceidEnabled && biometricStore.isAppLocked {
                LoginView()
            } else {
                ContentView()
            }
        }
        .onAppear {
            biometricStore.GetCurrentBiometricsSavedState()
            if biometricStore.isFaceidEnabled {
                biometricStore.ValidateBiometrics()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
            debugPrint("Moving to the background!")
//            getLockStatusFromGlobalSettings()
            if biometricStore.isFaceidEnabled && biometricStore.isAutoLockEnabled {
                biometricStore.isAppLocked = true
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            debugPrint("Moving to the foreground!")
            if biometricStore.isFaceidEnabled && biometricStore.isAutoLockEnabled {
                biometricStore.ValidateBiometrics()
            }
        }
    }
}

//#Preview {
//    AuthenticationView()
//        .environmentObject(BiometricStore())
//}
