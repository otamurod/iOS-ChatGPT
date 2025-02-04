//
//  RootView.swift
//  iOS ChatGPT
//
//  Created by Otamurod Safarov on 15/07/24.
//

import SwiftUI

struct RootView: View {
    @ObservedObject private var model = AppModel()

    var body: some View {
        TabView {
            ModulesView()
                .tabItem {
                    Image(systemName: "rectangle.stack.fill")
                    Text("Modules")
                }
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
        }
        .environmentObject(model)
        .preferredColorScheme(
            model.displayMode == "System" ? .none : (model.displayMode == "Dark" ? .dark : .light)
        )
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
