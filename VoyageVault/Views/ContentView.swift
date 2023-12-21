import SwiftUI

struct ContentView: View {
    @Binding var showSignInView: Bool
    @State private var selectedTab: Int = 2
    
    let backgroundColor = Color(red: 248/255, green: 233/255, blue: 223/255)
    
    init(showSignInView: Binding<Bool>) {
        self._showSignInView = showSignInView
        UINavigationBar.appearance().tintColor = UIColor(red: 199/255, green: 92/255, blue: 0, alpha: 1)
        UITabBar.appearance().unselectedItemTintColor = UIColor(red: 199/255, green: 92/255, blue: 0, alpha: 0.6)
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HistoryView()
                .tabItem {
                    Label("History", systemImage: "tray.full.fill")
                }
                .tag(0)
            
            MapDisplayView()
                .tabItem {
                    Label("Map", systemImage: "map")
                }
                .tag(1)
            
            Profile(showSignInView: $showSignInView)
                .tabItem {
                    Label("Statistics", systemImage: "chart.bar.xaxis")
                }
                .tag(2)
        }
        .accentColor(Color(red: 199/255, green: 92/255, blue: 0))
        .background(backgroundColor)
        .onAppear {
            selectedTab = 1
        }
    }
}
