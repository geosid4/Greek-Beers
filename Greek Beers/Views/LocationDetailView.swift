//
//  LocationDetailView.swift
//  Greek Beers
//
//  Created by George Sidiropoulos on 13/7/23.
//

import SwiftUI

struct LocationDetailView: View {
    
    let location: Location
    
    var body: some View {
        ScrollView {
            VStack {
                imageSelection
                    .shadow(color: Color.black.opacity(0.3), radius: 20, x:0, y:10)
                
                VStack(alignment: .leading, spacing: 16){
                    titleSection
                    Divider()
                    descriptionSection
                    Divider()
                    
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            }
        }
        .ignoresSafeArea()
    }
}

struct LocationDetailView_Previews: PreviewProvider {
    static var previews: some View {
        LocationDetailView(location: LocationDataService.locations.first!)
    }
}

extension LocationDetailView {
    
    private var imageSelection: some View {
        TabView {
            ForEach(location.imageNames, id: \.self){
                Image($0)
                    .resizable()
                    .scaledToFill()
                    .frame(width: UIScreen.main.bounds.width)
                    .clipped()
            }
        }
        .frame(height: 500)
        .tabViewStyle(PageTabViewStyle())
    }
    
    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(location.name)
                .font(.largeTitle)
            Text(location.cityName)
                .font(.title3)
                .foregroundColor(.secondary)
        }
    }
    
    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(location.description)
                .font(.title3)
                .foregroundColor(.secondary)
            
            if let url = URL(string: location.link){
               Link("Ιστοσελίδα Μπύρας", destination: url)
                    .font(.headline)
                    .tint(.blue)
            }
        }
    }
}

