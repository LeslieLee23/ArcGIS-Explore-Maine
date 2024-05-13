//
//  PreplannedMapView.swift
//  ArcGISMaps
//
//  Created by Leslie Lee on 5/12/24.
//

import SwiftUI

struct PreplannedMapView: View {
  
  @ObservedObject var viewModel: PreplannedMapViewModel

  
  init(viewModel: PreplannedMapViewModel) {
    self.viewModel = viewModel
  }
  
  var body: some View {
    HStack {
      // If offlineMap is available, allow navigation to map detail view
      if viewModel.isClickable {
        NavigationLink{
          MapDetailView(viewModel: MapDetailViewModel(offlineMap: viewModel.offlineMap))
        } label: {
          MapItemView(viewModel: MapItemViewModel(portalItem: viewModel.offlineMapModel.preplannedMapArea.portalItem))
        }
      } else {
        MapItemView(viewModel: MapItemViewModel(portalItem: viewModel.offlineMapModel.preplannedMapArea.portalItem))
      }
      Button {} label: {
        switch viewModel.downloadStatus {
        case .notStarted:
          Image(systemName: "icloud.and.arrow.down")
        case .downloading:
          ProgressView()
        case .downloaded:
          Image(systemName: "trash")
            .foregroundColor(.red)
        default:
          Image(systemName: "exclamationmark.icloud")
            .foregroundColor(.red)
        }
      }
      .padding(6)
      .background(Color.gray.opacity(0.1))
      .clipShape(Circle())
      .onTapGesture {
        Task {
          await viewModel.actionButtonPressed()
        }
      }
    }
  }
}

