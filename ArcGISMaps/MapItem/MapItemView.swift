//
//  MapItemView.swift
//  ArcGISMaps
//
//  Created by Leslie Lee on 5/9/24.
//

import SwiftUI
import ArcGIS

struct MapItemView: View {
  
  @ObservedObject var viewModel: MapItemViewModel
  
  init(viewModel: MapItemViewModel) {
    self.viewModel = viewModel
  }
  
  var body: some View {
    if let mapItem = viewModel.mapItem {
      HStack(spacing: 8){
        
        if let thumbnail = mapItem.thumbnail {
          Image(uiImage: thumbnail)
            .resizable()
            .aspectRatio(contentMode: .fit)
        } else {
          Image(systemName: "photo.artframe")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .foregroundColor(Color.gray.opacity(0.2))
        }
        
        VStack(spacing: 2) {
          Text(mapItem.title)
            .font(.system(size: 17))
            .frame(maxWidth: .infinity, alignment: .leading)
          
          Text(mapItem.description)
            .font(.system(size: 12))
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundColor(.gray)
        }
        .frame(maxHeight: .infinity)
      }
      .frame(height: 70)
    } else {
      ProgressView().frame(maxWidth: .infinity)
        .frame(height: 70)
    }
  }
}

