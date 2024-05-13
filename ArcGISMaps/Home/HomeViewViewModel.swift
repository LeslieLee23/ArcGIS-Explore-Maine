//
//  HomeViewViewModel.swift
//  ArcGISMaps
//
//  Created by Leslie Lee on 5/11/24.
//
import ArcGIS
import Combine
import Foundation

@MainActor
class HomeViewViewModel: ObservableObject {
  
  @Published var webMap: PortalItem?
  @Published var errorMessage: String?
  
  private let temporaryDirectory: URL
  private let offlineMapTask: OfflineMapTask?
  
  @Published private(set) var offlineMapModels: Result<[OfflineMapModel], Error>?
  
  var allOfflineMapModels: [OfflineMapModel] {
    guard case .success(let models) = offlineMapModels else {
      return []
    }
    return models
  }
  
  let portalItemID = "3bc3179f17da44a0ac0bfdac4ad15664"
  
  init() {
    let portal = Portal.arcGISOnline(connection: .anonymous)
    temporaryDirectory = FileManager.createTemporaryDirectory()
    
    if let itemID = PortalItem.ID(portalItemID) {
      webMap = PortalItem(portal: portal, id: itemID)
      offlineMapTask = OfflineMapTask(portalItem: PortalItem(portal: portal, id: itemID))
    } else {
      webMap = nil
      offlineMapTask = nil
      errorMessage = "Error finding webmap: Invalid item ID."
    }
  }
  
  private func makeOfflineMapModels() async {
    do {
      let mapAreas = try await offlineMapTask!.preplannedMapAreas.sorted(using: KeyPathComparator(\.portalItem.title))
      let models = mapAreas.compactMap {
        OfflineMapModel(
          preplannedMapArea: $0,
          offlineMapTask: offlineMapTask!,
          temporaryDirectory: temporaryDirectory
        )
      }
      offlineMapModels = .success(models)
    } catch {
      offlineMapModels = .failure(error)
      errorMessage = "Error loading preplanned map: \(error.localizedDescription)"
    }
  }
  
  deinit {
    try? FileManager.default.removeItem(at: temporaryDirectory)
  }
  
  @MainActor
  func loadMaps() {
    Task {
      await loadWebMap()
      await makeOfflineMapModels()
    }
  }
  
  @MainActor
  private func loadWebMap() async {
    guard let webMap = self.webMap else {
      errorMessage = "Error finding webmap: The webmap is not available."
      return
    }
    
    do {
      try await webMap.load()
      self.webMap = webMap
    } catch {
      errorMessage = "Error loading webmap: \(error.localizedDescription)"
    }
  }
}


private extension FileManager {
  /// Creates a temporary directory and returns the URL of the created directory.
  static func createTemporaryDirectory() -> URL {
    // swiftlint:disable:next force_try
    try! FileManager.default.url(
      for: .itemReplacementDirectory,
      in: .userDomainMask,
      appropriateFor: FileManager.default.temporaryDirectory,
      create: true
    )
  }
}
