//
//  SettingsView.swift
//  Pantry
//
//  Created by nabbit on 06/11/2023.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var biometricStore: BiometricStore
    @ObservedObject var syncMonitor: SyncMonitor = SyncMonitor.shared
    @State var canShowSyncError: Bool = false
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
                                .onChange(of: self.biometricStore.isFaceidEnabled,
                                {
                                    let selectionFeedback = UISelectionFeedbackGenerator()
                                    selectionFeedback.selectionChanged()
                                    if self.biometricStore.isFaceidEnabled {
                                        self.biometricStore.ValidateBiometrics()
                                    } else {
                                        self.biometricStore.isAutoLockEnabled = false
                                    }
                                })
                        }
                        HStack {
                            Image(systemName: "lock.badge.clock")
                                .foregroundStyle(.red)
                            // Causes `kCFRunLoopCommonModes` / `CFRunLoopRunSpecific` error
                            Toggle("Enable Auto-Lock", isOn: $biometricStore.isAutoLockEnabled)
                                .padding([.leading, .trailing])
                                .onChange(of: self.biometricStore.isAutoLockEnabled,
                                {
                                    let selectionFeedback = UISelectionFeedbackGenerator()
                                    selectionFeedback.selectionChanged()
                                })
                                .disabled(!self.biometricStore.isFaceidEnabled)
                        }
                    }
                }
                Section(content: {
                    HStack {
                        Image(systemName: self.syncMonitor.syncStateSummary.symbolName)
                            .foregroundColor(self.syncMonitor.syncStateSummary.symbolColor)
                        Text("iCloud Sync Status")
                        Spacer()
                        Button {
                            let feedbackGenerator: UINotificationFeedbackGenerator? = UINotificationFeedbackGenerator()
                            feedbackGenerator?.notificationOccurred(.error)
                            self.canShowSyncError.toggle()
                        } label: {
                            HStack {
                                Image(systemName: "info.circle")
                            }
                        }
                        .foregroundStyle(SyncMonitor.shared.syncError || SyncMonitor.shared.notSyncing ? .blue : .gray)
                        .disabled(SyncMonitor.shared.syncError || SyncMonitor.shared.notSyncing  ? false : true)
                    }
                    if self.canShowSyncError {
                        VStack {
                            HStack {
                                Group {
                                    if self.syncMonitor.syncError {
                                        VStack {
                                            HStack {
                                                if self.syncMonitor.setupError != nil {
                                                    Image(systemName: "xmark.icloud").foregroundColor(.red)
                                                }
                                                if self.syncMonitor.importError != nil {
                                                    Image(systemName: "icloud.and.arrow.down").foregroundColor(.red)
                                                }
                                                if self.syncMonitor.exportError != nil {
                                                    Image(systemName: "icloud.and.arrow.up").foregroundColor(.red)
                                                }
                                            }
                                        }
                                    } else if self.syncMonitor.notSyncing {
                                        Image(systemName: "xmark.icloud")
                                    } else {
                                        Image(systemName: "icloud").foregroundColor(.green)
                                    }
                                }
                            }
                            .padding(.bottom)
                            VStack(spacing: 10) {
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
                        }
                    }
                }, header: {
                    Text("\(Image(systemName: "clock.arrow.circlepath")) Backup")
                }, footer: {
                    Text("")
                })
                Section(header: Text("\(Image(systemName: "message")) FeedBack")) {
                    Group {
                        HStack {
                            Link(destination: URL(string: self.mailURL)!) {
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
                            Link(destination: URL(string: self.twitterURL)!) {
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
                                let AV = UIActivityViewController(activityItems: [self.appURL + self.appID], applicationActivities: nil)
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
                            Link(destination: URL(string: self.appURL + self.appID + self.reviewForwarder)!) {
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
                            Text("Version \(self.versionString)")
                        }
                        HStack {
                            Link(destination: URL(string: self.githubURL)!) {
                                HStack {
                                    Image(systemName: "paintbrush.fill")
                                        .foregroundStyle(.orange)
                                    Text("Designed by Plus1XP")
                                        .foregroundColor(.primary)
                                }
                            }
                        }
                        HStack {
                            Link(destination: URL(string: self.githubURL)!) {
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
