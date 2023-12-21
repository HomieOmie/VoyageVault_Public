//
//  OnboardingView.swift
//  VoyageVault
//
//  Created by Matthew Leboffe on 12/4/23.
//

import Foundation
import SwiftUI

struct OnboardingView: View {
    @Binding var isFirstLaunch: Bool
    @State private var selection = 0
    private let totalPages = 9
    
    var body: some View {
        VStack {
            TabView(selection: $selection) {
                OnboardingPageView(title: "Welcome to VoyageVault", description: "Your ultimate travel companion.", imageName: "globe").tag(0)
                OnboardingPageView(title: "Discover New Places", description: "Find amazing new destinations.", imageName: "map").tag(1)
                OnboardingPageView(title: "Plan Your Journey", description: "Organize your travel itinerary with ease.", imageName: "airplane").tag(2)
                OnboardingPageView(title: "Local Insights", description: "Get the insider's view on your next destination.", imageName: "person.3.sequence").tag(3)
                OnboardingPageView(title: "Stay Connected", description: "Share your experiences with fellow travelers.", imageName: "message").tag(4)
                OnboardingPageView(title: "Travel Safely", description: "Safety tips and updates for peace of mind.", imageName: "lock.shield").tag(5)
                OnboardingPageView(title: "Explore Cultures", description: "Dive into the local culture and history.", imageName: "books.vertical").tag(6)
                OnboardingPageView(title: "Find Hidden Gems", description: "Discover places off the beaten path.", imageName: "magnifyingglass").tag(7)
                OnboardingPageView(title: "Ready to Start?", description: "Begin your adventure with VoyageVault!", imageName: "arrow.right.circle").tag(8)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
            
            Button(action: {
                UserDefaults.standard.set(true, forKey: "HasLaunchedOnce")
                isFirstLaunch = false
            }) {
                Text(selection == totalPages - 1 ? "Let's Go" : "Skip")
                    .frame(maxWidth: .infinity)
                    .padding()
            }
            .foregroundColor(selection == totalPages - 1 ? OnboardingPageView.backgroundColor : OnboardingPageView.textColor)
            .background(selection == totalPages - 1 ? OnboardingPageView.textColor : OnboardingPageView.backgroundColor)
            .cornerRadius(10)
            .padding(.horizontal, 40)
            .padding(.bottom, 40)
        }
        .background(OnboardingPageView.backgroundColor)
        .edgesIgnoringSafeArea(.all)
    }
}
