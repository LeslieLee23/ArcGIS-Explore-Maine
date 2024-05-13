//
//  HomeView.swift
//  ArcGISMaps
//
//  Created by Leslie Lee on 5/9/24.
//

import SwiftUI
import ArcGIS

struct HomeView: View {
  @ObservedObject var viewModel =  HomeViewViewModel()
  @State private var showAlert = false
  
  var body: some View {
    if let webMap = viewModel.webMap {
      NavigationStack {
        List {
          Section(header: Text("Web Map")) {
            NavigationLink{
              MapDetailView(viewModel: MapDetailViewModel(portalItem: webMap))
            } label: {
              MapItemView(viewModel: MapItemViewModel(portalItem: webMap))
            }
          }
          Section(header: Text("Map Areas")) {
            ForEach(viewModel.allOfflineMapModels) { model in
              PreplannedMapView(viewModel: PreplannedMapViewModel(offlineMapModel: model))
            }
          }
        }
        .navigationTitle(webMap.title)
        .navigationBarTitleDisplayMode(.inline)
        .listStyle(PlainListStyle())
      }
      .onAppear {
        viewModel.loadMaps()
      }
      .alert("Error", isPresented: $showAlert, actions: {
        Button("Retry") {
          viewModel.loadMaps()
        }
        Button("Cancel", role: .cancel) { }
      }, message: {
        Text(viewModel.errorMessage ?? "Unknown error")
      })
      .onChange(of: viewModel.errorMessage) { _, newValue in
        showAlert = newValue != nil
      }
    } else {
      ProgressView().frame(maxWidth: .infinity)
    }
  }
}

#Preview {
  HomeView()
}
