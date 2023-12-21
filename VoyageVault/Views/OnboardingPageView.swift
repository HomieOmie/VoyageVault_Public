//
//  OnboardingPageView.swift
//  VoyageVault
//
//  Created by Matthew Leboffe on 12/4/23.
//

import Foundation
import SwiftUI

struct OnboardingPageView: View {
    var title: String
    var description: String
    var imageName: String
    
    static let textColor = Color(red: 199/255, green: 92/255, blue: 0)
    static let backgroundColor = Color(red: 248/255, green: 233/255, blue: 223/255)
    
    var body: some View {
        VStack {
            Image(systemName: imageName)
                .resizable()
                .scaledToFit()
                .frame(height: 200)
                .padding(.bottom, 20)
                .foregroundColor(OnboardingPageView.textColor)
            
            Text(title)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(OnboardingPageView.textColor)
            
            Text(description)
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .padding()
                .foregroundColor(OnboardingPageView.textColor)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(OnboardingPageView.backgroundColor)
    }
}
