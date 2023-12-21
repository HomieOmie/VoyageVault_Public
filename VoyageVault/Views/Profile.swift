//
//  Profile.swift
//  VoyageVault
//
//  Created by Matthew Leboffe on 11/1/23.
//

import SwiftUI

struct Profile: View {
    @StateObject private var viewModel = ProfileViewModel()
    @Binding var showSignInView: Bool
    
    let backgroundColor = Color(red: 248/255, green: 233/255, blue: 223/255)
    let darkColor = Color(red: 199/255, green: 92/255, blue: 0)
    
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    if let user = viewModel.currentUser {
                        HStack(spacing: 15) {
                            if let urlString = user.photoUrl, let url = URL(string: urlString) {
                                AsyncImage(url: url) { image in
                                    image.resizable()
                                        .aspectRatio(contentMode: .fill)
                                } placeholder: {
                                    ProgressView()
                                }
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                            } else {
                                Image(systemName: "person.crop.circle.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 100, height: 100)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                            }
                            
                            VStack(alignment: .leading) {
                                Text(user.name ?? "N.A.")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(darkColor)
                                Text(user.email ?? "N.A.")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                        .padding(.horizontal)
                        .cornerRadius(10)
                    }
                }
                HStack {
                    Spacer()
                    Text("🏆")
                        .font(.system(size: 40))
                    VStack(alignment: .leading) {
                        Text("Top \(viewModel.topTravelerPercentage) of travelers")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(Color(red: 199/255, green: 92/255, blue: 0))
                    }
                    Spacer()
                }
                .padding(.vertical, 10)
                .background(RoundedRectangle(cornerRadius: 20).fill(backgroundColor))
                .padding()
                
                HStack {
                    Spacer()
                    Text("❤️")
                        .font(.system(size: 40))
                    VStack(alignment: .leading) {
                        Text("\(viewModel.favoriteCity)")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(Color(red: 199/255, green: 92/255, blue: 0))
                        Text("Your favorite city")
                            .font(.headline)
                            .fontWeight(.regular)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
                .padding(.vertical, 10)
                .background(RoundedRectangle(cornerRadius: 20).fill(backgroundColor))
                .padding()
                
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                    StatisticView(icon: "📍", label: "Pins around the world", value: "\(viewModel.totalPins)")
                    StatisticView(icon: "🏙️", label: "Cities Visited", value: "\(viewModel.uniqueCities)")
                    StatisticView(icon: "🌍", label: "Continents Visited", value: "\(viewModel.uniqueContinents)")
                    StatisticView(icon: "🗺️", label: "Countries Visited", value: "\(viewModel.uniqueCountries)")
                    StatisticView(icon: "☀️", label: "Most Frequent Travels", value: "\(viewModel.mostFrequentSeason)")
                    StatisticView(icon: "📷", label: "Most Common Pin Type", value: "\(viewModel.mostCommonPinType)")
                    StatisticView(icon: "⬇️", label: "Most Southern Point Visited", value: "\(viewModel.mostSouthernPoint)")
                    StatisticView(icon: "⬆️", label: "Most Northern Point Visited", value: "\(viewModel.mostNorthernPoint)")
                }
                .padding()
                
                HStack {
                    Button("Sign Out") {
                        Task {
                            do {
                                try viewModel.signOut()
                                showSignInView = true
                            } catch {
                                print(error)
                            }
                        }
                    }
                    .fontWeight(.bold)
                    .foregroundColor(Color.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(darkColor)
                    .cornerRadius(10)
                    .padding(.horizontal, 40)
                    .accessibility(identifier: "signOutButton")
                }
            }.navigationTitle("Statistics")
        }
    }
}

import SwiftUI

struct StatisticView: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        VStack(spacing: 8) {
            Text(icon)
                .font(.system(size: 40))
                .foregroundColor(Color.blue)

            Text(value)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(Color(red: 199/255, green: 92/255, blue: 0))

            Text(label)
                .font(.footnote)
                .foregroundColor(Color.black)
                .font(.system(size: 10))
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 14)
        .frame(minWidth: 0, maxWidth: .infinity)
        .background(Color(red: 248/255, green: 233/255, blue: 223/255))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(red: 199/255, green: 92/255, blue: 0), lineWidth: 3)
        )
        .cornerRadius(12)
    }
}
