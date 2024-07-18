//
//  AffirmationView.swift
//  iOS ChatGPT
//
//  Created by Otamurod Safarov on 18/07/24.
//

import SwiftUI

struct AffirmationView: View {
    @EnvironmentObject private var model: AppModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                if model.isAffirmationScreenEmpty {
                    Text("Tap 'Generate' on the Top-Right corner of the screen")
                        .font(.system(size: 18))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding()
                }

                if model.isThinking {
                    VStack {
                        Text("Generating affirmation...")
                        ProgressView().progressViewStyle(.circular)
                    }
                }

                if model.hasResultAffirmationScreen {
                    ResultView(generatedText: model.generatedAffirmation)
                }
            }
            .padding(.vertical, 32)
            .navigationTitle("Affirmation")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { screenToolBar }
        }
    }

    private var screenToolBar: some ToolbarContent {
        Group {
            ToolbarItem(placement: .navigationBarLeading) {
                HStack {
                    Button("Close") {
                        dismiss()
                    }
                    if !model.generatedAffirmation.isEmpty {
                        Button("Reset") {
                            model.generatedAffirmation = ""
                        }
                    }
                }
            } // ToolbarItem

            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Generate") {
                    Task {
                        await model.makeAffirmation()
                    }
                }.disabled(model.isThinking)
            } // ToolbarItem
        } // Group
    } // screenToolBar
}

struct AffirmationView_Previews: PreviewProvider {
    static var previews: some View {
        AffirmationView().environmentObject(AppModel())
    }
}
