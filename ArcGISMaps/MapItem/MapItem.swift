//
//  MapItem.swift
//  ArcGISMaps
//
//  Created by Leslie Lee on 5/9/24.
//

import Foundation
import SwiftUI
import ArcGIS


struct MapItem: Equatable, Identifiable {
  var id: UUID
  var portalItemID: String
  var title: String
  var description: String
  var thumbnail: UIImage?
}
