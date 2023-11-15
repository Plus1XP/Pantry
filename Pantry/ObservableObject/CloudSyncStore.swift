//
//  CloudSyncService.swift
//  Pantry
//
//  Created by nabbit on 14/11/2023.
//

import SwiftUI

class CloudSyncStore: ObservableObject {
    
    @ObservedObject var syncMonitor = SyncMonitor.shared
    
    @State private var isDeletionAlertPresented: Bool = false
    @State private var isDeletionBannerPresented: Bool = false
    @State private var hasIcloudDeletedSuccessfuly: Bool = false

    @Published var isIcloudEnabled: Bool = false {
        didSet {
            isIcloudEnabledSavedState = isIcloudEnabled
            debugPrint("Get AutoLock Saved State from AppStorage")
        }
    }
    
    @AppStorage("isIcloudEnabled") var isIcloudEnabledSavedState: Bool = false

    func GetCurrentCloudSyncSavedState() -> Void {
        isIcloudEnabled = isIcloudEnabledSavedState
    }
    
//    func canDeleteIcloudData(isCloudKitEnabled: Bool) -> Void {
//        if isCloudKitEnabled == false {
//            isDeletionAlertPresented = true
//        }
//    }
//
//    func GetdeletionBanner() -> BannerData {
//        if hasIcloudDeletedSuccessfuly {
//            return iCloudDeleteSuccessfulBanner
//        } else {
//            return iCloudDeleteErrorBanner
//        }
//    }
//
//    private var deletionAlert: Alert {
//        let message: String = "This is an irreversable action.\nPlease ensure you have a backup."
//        return Alert(title: Text("Delete iCloud data?"),
//                     message: Text(NSLocalizedString(message, comment: .empty)),
//                     primaryButton: .cancel(Text("Turn off, KEEP data"), action: cancelDeletion),
//                     secondaryButton: .destructive(Text("Turn off, DELETE data"), action: performDeletion))
//    }
//
//    private func performDeletion() {
//        (UIApplication.shared.delegate as? AppDelegate)?.RemoveiCloudData() { (result) in
//            if result {
//                hasIcloudDeletedSuccessfuly = true
//            } else {
//                hasIcloudDeletedSuccessfuly = false
//            }
//            debugPrint("iCloud Banner Displayed: \(result)")
//            isDeletionBannerPresented = true
//            DismissBanner()
//        }
//    }
//
//    /// Returns a user-displayable text description of the sync state
//    func stateText(for state: SyncMonitor.SyncState) -> String {
//        switch state {
//        case .notStarted:
//            return "Not started"
//        case .inProgress(started: let date):
//            return "In progress since \(dateFormatter.string(from: date))"
//        case let .succeeded(started: _, ended: endDate):
//            return "Suceeded at \(dateFormatter.string(from: endDate))"
//        case let .failed(started: _, ended: endDate, error: _):
//            return "Failed at \(dateFormatter.string(from: endDate))"
//        }
//    }
//
//    func stateIcon(for state: SyncMonitor.SyncState) -> String {
//        switch state {
//        case .notStarted:
//            return "bolt.horizontal.icloud"
//        case .inProgress:
//            return "arrow.clockwise.icloud"
//        case .succeeded:
//            return "icloud"
//        case .failed:
//            return "exclamationmark.icloud"
//        }
//    }
//
//    func stateColour(for state: SyncMonitor.SyncState) -> Color {
//        switch state {
//        case .notStarted:
//            return .gray
//        case .inProgress:
//            return .yellow
//        case .succeeded:
//            return .green
//        case .failed:
//            return .red
//        }
//    }
//    
//    var dateFormatter: DateFormatter = {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateStyle = DateFormatter.Style.short
//        dateFormatter.timeStyle = DateFormatter.Style.short
//        return dateFormatter
//    }()
}
