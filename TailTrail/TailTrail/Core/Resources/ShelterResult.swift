//
//  ShelterResult.swift
//  TailTrail
//
//  Created by Jesse Liao on 3/10/24.
//

import SwiftUI
import MapKit

struct ShelterResult: View {
    @EnvironmentObject var viewModel: ShelterViewModel
    @Environment(\.colorScheme) var colorScheme
    var result: MKMapItem
    
    var body: some View {
        let address = viewModel.constructAddressString(for: result)
        
        VStack(spacing: 0) {
            if let name = result.name {
                ShelterTitle(title: name)
            }
            
            if let contact = result.phoneNumber {
                let phoneUrl = String("tel: \(contact)")
                if let url = URL(string: phoneUrl) {
                    ShelterLink(icon: "phone.circle.fill", linkText: contact, url: url)
                }
            }
            
            if let website = result.url?.absoluteString {
                if let url = URL(string: website) {
                    ShelterLink(icon: "link.circle.fill", linkText: website, url: url)
                }
            }
            
            let encodedAddress = address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            let mapUrl = String("http://maps.apple.com/?address=\(encodedAddress)")
            if let url = URL(string: mapUrl) {
                ShelterLink(icon: "map.circle.fill", linkText: address, url: url)
            }
        }
        .padding(.leading, 25)
        .padding(.vertical, 20)
        
        if !viewModel.searchResults.isEmpty && result != viewModel.searchResults[viewModel.searchResults.count-1] {
            Rectangle()
                .fill(colorScheme == .light ? Color.meowGray : .white)
                .frame(height: 2)
                .edgesIgnoringSafeArea(.horizontal)
        }
    }
}

struct ShelterTitle: View {
    @Environment(\.colorScheme) var colorScheme
    let title: String
    
    var body: some View {
        HStack {
            Text("\(title)")
                .font(.customSubtitle)
                .bold()
                .foregroundColor(colorScheme == .light ? .black : .white)
            Spacer()
        }
        .padding(.vertical, 2)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct ShelterLink: View {
    @Environment(\.colorScheme) var colorScheme
    let icon: String
    let linkText: String
    let url: URL
    
    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            Image(systemName: icon)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 15, height: 15)
                .padding(.top, 2)
                .foregroundColor(colorScheme == .light ? .black : .white)
            Link(destination: url) {
                Text(linkText)
                    .font(.customText)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 10)
                    .multilineTextAlignment(.leading)
                    .foregroundColor(colorScheme == .light ? .black : .white)
            }
        }
        .padding(.vertical, 4)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
