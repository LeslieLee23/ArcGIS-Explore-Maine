//
//  ArcGISMapsApp.swift
//  ArcGISMaps
//
//  Created by Leslie Lee on 5/9/24.
//

import SwiftUI
import ArcGIS

@main
struct ArcGISMapsApp: App {
  init() {
      ArcGISEnvironment.apiKey = APIKey(EnvironmentConfig.apiKey)
  }
  var body: some SwiftUI.Scene {
      WindowGroup {
          HomeView()
      }
  }
}
