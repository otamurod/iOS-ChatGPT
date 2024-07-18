//
//  NextView.swift
//  iOS ChatGPT
//
//  Created by Otamurod Safarov on 18/07/24.
//

import SwiftUI

struct NextView: View {
    @EnvironmentObject private var model: AppModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                if model.isNextScreenEmpty {
                    Text("Tap 'Generate' on the Top-Right corner of the screen")
                        .font(.system(size: 18))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding()
                }

                if model.isThinking {
                    VStack {
                        Text("Generating next...")
                        ProgressView().progressViewStyle(.circular)
                    }
                }

                if model.hasResultNextScreen {
                    ResultView(generatedText: model.generatedNext)
                }
            }
            .padding(.vertical, 32)
            .navigationTitle("Next")
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
                    if !model.generatedConcept.isEmpty {
                        Button("Reset") {
                            model.generatedNext = ""
                        }
                    }
                }
            } // ToolbarItem

            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Generate") {
                    Task {
                        await model.makeNext()
                    }
                }.disabled(model.isThinking)
            } // ToolbarItem
        } // Group
    } // screenToolBar
}

struct NextView_Previews: PreviewProvider {
    static var previews: some View {
        NextView().environmentObject(AppModel())
    }
}
