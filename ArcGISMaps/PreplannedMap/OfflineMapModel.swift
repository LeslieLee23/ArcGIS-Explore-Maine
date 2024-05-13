//
//  OfflineMapModel.swift
//  ArcGISMaps
//
//  Created by Leslie Lee on 5/11/24.
//

import ArcGIS
import Combine
import Foundation

class OfflineMapModel: ObservableObject, Identifiable {
    /// The preplanned map area.
    let preplannedMapArea: PreplannedMapArea
    
    /// The task to use to take the area offline.
    let offlineMapTask: OfflineMapTask
    
    /// The directory where the mmpk will be stored.
    let mmpkDirectory: URL
    
    /// The currently running download job.
    @Published private(set) var job: DownloadPreplannedOfflineMapJob?
    
    /// The result of the download job.
    @Published private(set) var result: Result<MobileMapPackage, Error>?
    
    init?(preplannedMapArea: PreplannedMapArea, offlineMapTask: OfflineMapTask, temporaryDirectory: URL) {
        self.preplannedMapArea = preplannedMapArea
        self.offlineMapTask = offlineMapTask
        
        if let itemID = preplannedMapArea.portalItem.id {
            self.mmpkDirectory = temporaryDirectory
                .appendingPathComponent(itemID.rawValue)
                .appendingPathExtension("mmpk")
        } else {
            return nil
        }
    }
    
    deinit {
        Task { [job] in
            // Cancel any outstanding job.
            await job?.cancel()
        }
    }
}

extension OfflineMapModel: Hashable {
    static func == (lhs: OfflineMapModel, rhs: OfflineMapModel) -> Bool {
        lhs === rhs
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}

extension OfflineMapModel {
    /// A Boolean value indicating whether the map is being taken offline.
    var isDownloading: Bool {
        job != nil
    }
}

@MainActor
extension OfflineMapModel {
    /// Downloads the given preplanned map area.
    /// - Parameter preplannedMapArea: The preplanned map area to be downloaded.
    /// - Precondition: `canDownload`
    func download() async {
        precondition(canDownload)
        
        let parameters: DownloadPreplannedOfflineMapParameters
        
        do {
            // Creates the parameters for the download preplanned offline map job.
            parameters = try await makeParameters(area: preplannedMapArea)
        } catch {
            // If creating the parameters fails, set the failure.
            self.result = .failure(error)
            return
        }
        
        // Creates the download preplanned offline map job.
        let job = offlineMapTask.makeDownloadPreplannedOfflineMapJob(
            parameters: parameters,
            downloadDirectory: mmpkDirectory
        )
        self.job = job
        
        // Starts the job.
        job.start()
        
        // Awaits the output of the job and assigns the result.
        result = await job.result.map { $0.mobileMapPackage }
        // Sets the job to nil
        self.job = nil
    }
    
    /// A Boolean value indicating whether the offline map can be downloaded.
    /// This returns `false` if the map was already downloaded successfully or is in the process
    /// of being downloaded.
    var canDownload: Bool {
        !(isDownloading || downloadDidSucceed)
    }
    
    /// A Boolean value indicating whether the download succeeded.
    var downloadDidSucceed: Bool {
        if case .success = result {
            return true
        } else {
            return false
        }
    }
    
    /// Creates the parameters for a download preplanned offline map job.
    /// - Parameter preplannedMapArea: The preplanned map area to create parameters for.
    /// - Returns: A `DownloadPreplannedOfflineMapParameters` if there are no errors.
    func makeParameters(area: PreplannedMapArea) async throws -> DownloadPreplannedOfflineMapParameters {
        // Creates the default parameters.
        let parameters = try await offlineMapTask.makeDefaultDownloadPreplannedOfflineMapParameters(preplannedMapArea: area)
        // Sets the update mode to no updates as the offline map is display-only.
        parameters.updateMode = .noUpdates
        return parameters
    }
    
    /// Cancels current download.
    func cancelDownloading() async {
        guard let job else {
            return
        }
        await job.cancel()
        self.job = nil
    }
    
    /// Removes the downloaded offline map (mmpk) from disk.
    func removeDownloadedContent() {
        result = nil
        try? FileManager.default.removeItem(at: mmpkDirectory)
    }
}
