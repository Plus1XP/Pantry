//
//  SettingsView.swift
//  Pantry
//
//  Created by nabbit on 06/11/2023.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var biometricStore: BiometricStore
    @EnvironmentObject var cloudSyncStore: CloudSyncStore
    @Environment(\.dismiss) var dismiss
    @ObservedObject var syncMonitor = SyncMonitor.shared
//    @AppStorage("isIcloudEnabled") var isIcloudEnabled: Bool = false
    // Fill in App ID when app is added to appstore connect!
    let appID: String = "1628565468"
    let mailURL: String = "mailto:evlbrains@protonmail.ch"
    let twitterURL: String = "https://twitter.com/evlbrains"
    let appURL: String = "https://apps.apple.com/us/app/id"
    let reviewForwarder: String = "?action=write-review"
    let githubURL: String = "https://github.com/Plus1XP"

    private let versionString: String = {
            let version: String = (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String) ?? "_error"
            let build: String = (Bundle.main.infoDictionary?["CFBundleVersion"] as? String) ?? "_error"
            return version + " (" + build + ")"
    }()
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("\(Image(systemName: "lock")) Security")) {
                    Group {
                        HStack {
                            Image(systemName: "faceid")
                                .foregroundStyle(.green)
                            // Causes `kCFRunLoopCommonModes` / `CFRunLoopRunSpecific` error
                            Toggle("Enable Face ID", isOn: $biometricStore.isFaceidEnabled)
                                .padding([.leading, .trailing])
                                .onChange(of: biometricStore.isFaceidEnabled,
                                {
                                    if biometricStore.isFaceidEnabled {
                                        biometricStore.ValidateBiometrics()
                                    }
                                })
                        }
                        HStack {
                            Image(systemName: "lock.badge.clock")
                                .foregroundStyle(.red)
                            // Causes `kCFRunLoopCommonModes` / `CFRunLoopRunSpecific` error
                            Toggle("Enable Auto-Lock", isOn: $biometricStore.isAutoLockEnabled)
                                .padding([.leading, .trailing])
                        }
                    }
                }
                Section(header: Text("\(Image(systemName: "clock.arrow.circlepath")) Backup")) {
                    Group {
                        VStack {
                            HStack {
                                Image(systemName: syncMonitor.syncStateSummary.symbolName)
                                    .foregroundColor(syncMonitor.syncStateSummary.symbolColor)
                                // Causes `kCFRunLoopCommonModes` / `CFRunLoopRunSpecific` error
                                Toggle("iCloud", isOn: $cloudSyncStore.isIcloudEnabled)
                                    .padding([.leading, .trailing])
                            }
                            HStack {
                                Text("TEST")
                                if SyncMonitor.shared.syncError {
                                    if let e = SyncMonitor.shared.setupError {
                                        Text("Unable to set up iCloud sync, changes won't be saved! \(e.localizedDescription)")
                                    }
                                    if let e = SyncMonitor.shared.importError {
                                        Text("Import is broken: \(e.localizedDescription)")
                                    }
                                    if let e = SyncMonitor.shared.exportError {
                                        Text("Export is broken - your changes aren't being saved! \(e.localizedDescription)")
                                    }
                                } else if SyncMonitor.shared.notSyncing {
                                    Text("Sync should be working, but isn't. Look for a badge on Settings or other possible issues.")
                                }
                            }
                            HStack {
                                Group {
                                    if syncMonitor.syncError {
                                        VStack {
                                            HStack {
                                                if syncMonitor.setupError != nil {
                                                    Image(systemName: "xmark.icloud").foregroundColor(.red)
                                                }
                                                if syncMonitor.importError != nil {
                                                    Image(systemName: "icloud.and.arrow.down").foregroundColor(.red)
                                                }
                                                if syncMonitor.exportError != nil {
                                                    Image(systemName: "icloud.and.arrow.up").foregroundColor(.red)
                                                }
                                            }
                                        }
                                    } else if syncMonitor.notSyncing {
                                        Image(systemName: "xmark.icloud")
                                    } else {
                                        Image(systemName: "icloud").foregroundColor(.green)
                                    }
                                }
                            }
                        }
                    }
                }
                Section(header: Text("\(Image(systemName: "message")) FeedBack")) {
                    Group {
                        HStack {
                            Link(destination: URL(string: mailURL)!) {
                                HStack {
                                    Image(systemName: "paperplane.fill")
                                        .foregroundStyle(.blue)
                                    Text("Email")
                                        .foregroundColor(.primary)
                                }
                            }
                            .disabled(true)
                        }
                        HStack {
                            Link(destination: URL(string: twitterURL)!) {
                                HStack {
                                    Image(systemName: "quote.bubble.fill")
                                        .foregroundStyle(.blue)
                                    Text("Tweet")
                                        .foregroundColor(.primary)
                                }
                            }
                            .disabled(true)
                        }
                        HStack {
                            Button {
                                let AV = UIActivityViewController(activityItems: [appURL+appID], applicationActivities: nil)
                                let scenes = UIApplication.shared.connectedScenes
                                let windowScene = scenes.first as? UIWindowScene
                                windowScene?.keyWindow?.rootViewController?.present(AV, animated: true, completion: nil)
                            } label: {
                                HStack {
                                    Image(systemName: "arrowshape.turn.up.forward.fill")
                                        .foregroundStyle(.blue)
                                    Text("Share")
                                        .foregroundColor(.primary)
                                }
                            }
                            .disabled(true)
                        }
                        HStack {
                            Link(destination: URL(string: appURL+appID+reviewForwarder)!) {
                                HStack {
                                    Image(systemName: "star.fill")
                                        .foregroundStyle(.yellow)
                                    Text("Rate")
                                        .foregroundColor(.primary)
                                }
                            }
                            .disabled(true)
                        }
                    }
                }
                Section(header: Text("\(Image(systemName: "info.circle")) About")) {
                    Group {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(.black, .yellow)
                            Text("Version \(versionString)")
                        }
                        HStack {
                            Link(destination: URL(string: githubURL)!) {
                                HStack {
                                    Image(systemName: "paintbrush.fill")
                                        .foregroundStyle(.orange)
                                    Text("Designed by Plus1XP")
                                        .foregroundColor(.primary)
                                }
                            }
                        }
                        HStack {
                            Link(destination: URL(string: githubURL)!) {
                                HStack {
                                    Image(systemName: "hammer.fill")
                                        .foregroundStyle(.gray)
                                    Text("Developed by Plus1XP")
                                        .foregroundColor(.primary)
                                }
                            }
                        }
                        HStack {
                            Image(systemName: "c.circle")
                                .foregroundStyle(.primary)
                            Text("Copyright 2022 Plus1XP")
                        }
                    }
                }
            }
            .navigationBarItems(
                leading:
                    Text("Settings")
                    .font(.largeTitle)
                    .fontWeight(.bold),
                trailing:
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "arrowshape.turn.up.backward")
                    })
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(BiometricStore())
}
