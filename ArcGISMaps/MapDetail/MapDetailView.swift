//
//  MapDetailView.swift
//  ArcGISMaps
//
//  Created by Leslie Lee on 5/10/24.
//

import SwiftUI
import ArcGIS

struct MapDetailView: View {
    @ObservedObject var viewModel: MapDetailViewModel

    var body: some View {
        Group {
            if let map = viewModel.map {
                MapView(map: map)
            } else if viewModel.isLoading {
                ProgressView()
            } else {
              errorView
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
  
  private var errorView: some View {
      if let errorMessage = viewModel.errorMessage {
          Text(errorMessage)
              .foregroundColor(.red)
              .padding()
      } else {
          Text("Map data is not available")
              .foregroundColor(.gray)
              .padding()
      }
  }
}

