//
//  RootView.swift
//  iOS ChatGPT
//
//  Created by Otamurod Safarov on 15/07/24.
//

import SwiftUI

struct RootView: View {
    var body: some View {
        TabView {
            ModulesView()
            SettingsView()
        }
    }
}

#Preview {
    RootView()
}
