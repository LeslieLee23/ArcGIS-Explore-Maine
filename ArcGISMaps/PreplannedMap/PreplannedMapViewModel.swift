//
//  PreplannedMapViewModel.swift
//  ArcGISMaps
//
//  Created by Leslie Lee on 5/12/24.
//

import Foundation
import Combine
import ArcGIS

@MainActor
class PreplannedMapViewModel: ObservableObject {
  @Published var downloadStatus: DownloadStatus = .notStarted
  @Published var offlineMap: Map?
  var isClickable: Bool {
      return offlineMap != nil
  }
  
  var offlineMapModel: OfflineMapModel
  
  init(offlineMapModel: OfflineMapModel) {
    self.offlineMapModel = offlineMapModel
  }
  
  func actionButtonPressed() async {
    if offlineMapModel.canDownload {
      downloadStatus = .downloading
      await offlineMapModel.download()
      
      switch offlineMapModel.result {
      case .success(let mmpk):
        offlineMap = mmpk.maps.first
          self.downloadStatus = .downloaded
          self.offlineMap = mmpk.maps.first
      case .failure(let error):
          self.downloadStatus = .failure(error)
      default:
          self.downloadStatus = .unknown

      }
    } else if offlineMapModel.downloadDidSucceed {
      offlineMapModel.removeDownloadedContent()
      self.downloadStatus = .notStarted
      offlineMap = nil
    } 
  }
  
  
}
enum DownloadStatus {
  case notStarted
  case downloading
  case downloaded
  case failure(Error)
  case unknown
}
