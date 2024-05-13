//
//  MapDetailViewModel.swift
//  ArcGISMaps
//
//  Created by Leslie Lee on 5/10/24.
//

import Foundation
import ArcGIS

@MainActor
class MapDetailViewModel: ObservableObject {
  @Published var map: Map?
  @Published var isLoading = false
  @Published var errorMessage: String?
  
  let portalItem: PortalItem?
  
  init(portalItem: PortalItem? = nil, offlineMap: Map? = nil) {
    self.portalItem = portalItem
    self.map = offlineMap
    if portalItem != nil {
      loadMap()
    }
  }
  
  func loadMap() {
    guard let portalItem = portalItem else { return }

    isLoading = true
    errorMessage = nil
    Task {
      do {
        try await portalItem.load()
        self.map = Map(item: portalItem)
        self.isLoading = false
      } catch {
        self.errorMessage = "Error loading map area: \(error.localizedDescription)"
        self.isLoading = false
      }
    }
    
  }
}

