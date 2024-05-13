//
//  MapItemViewModel.swift
//  ArcGISMaps
//
//  Created by Leslie Lee on 5/9/24.
//

import Foundation
import SwiftUI
import ArcGIS

@MainActor
class MapItemViewModel: ObservableObject {
  
  @Published var mapItem: MapItem?
  
  var portalItem: PortalItem
  
  init(portalItem: PortalItem) {
    self.portalItem = portalItem
    initMapItem()
  }
  
  private func initMapItem() {
    self.mapItem = MapItem(
      id: UUID(),
      portalItemID: self.portalItem.id!.rawValue,
      title: self.portalItem.title,
      description: self.portalItem.snippet,
      thumbnail: nil
    )
    Task {
      let image = await loadAndProcessThumbnail()
      self.mapItem?.thumbnail = image
    }
  }
  
  
  private func loadAndProcessThumbnail() async -> UIImage? {
    guard let thumbnail = portalItem.thumbnail else {
      return nil
    }
    
    do {
      try await thumbnail.load()
      return thumbnail.image
    } catch {
      return nil
    }
  }
}


