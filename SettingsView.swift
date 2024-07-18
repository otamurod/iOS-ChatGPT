//
//  SettingsView.swift
//  iOS ChatGPT
//
//  Created by Otamurod Safarov on 15/07/24.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var model: AppModel
    let displayOptions = ["Light", "Dark", "System"]

    var body: some View {
        NavigationStack {
            Form {
                Section("General") {
                    Picker("Display", selection: $model.displayMode) {
                        ForEach(displayOptions, id: \.self) {
                            Text($0)
                        }
                    }
                }

                Section("Contact") {
                    Button(action: {
                        EmailHelper.shared.sendEmail(subject: "iOS GPT v\(AppInfo.versionNumber)", body: "", to: AppInfo.supportEmail)
                    }) {
                        Label("Email support", systemImage: "tray.full.fill")
                    }
                }
            }.navigationTitle("Settings")
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView().environmentObject(AppModel())
    }
}
