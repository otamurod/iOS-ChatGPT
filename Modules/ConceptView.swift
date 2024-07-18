//
//  ConceptView.swift
//  iOS ChatGPT
//
//  Created by Otamurod Safarov on 16/07/24.
//

import SwiftUI

struct ConceptView: View {
    @EnvironmentObject private var model: AppModel
    @Environment(\.dismiss) private var dismiss
    @State var copyButtonTitle = "Copy"

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                if model.isConceptScreenEmpty {
                    Text("Tap 'Generate' on the Top-Right corner of the screen")
                        .font(.system(size: 18))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding()
                }

                if model.isThinking {
                    VStack {
                        Text("Generating random concept...")
                        ProgressView().progressViewStyle(.circular)
                    }
                }

                if model.hasResultConceptScreen {
                    ResultView(generatedText: model.generatedConcept, textSize: 28, showCopyButton: true, copyButtonTitle: $copyButtonTitle)
                }
            }
            .padding(.vertical, 32)
            .navigationTitle("Random Concept")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { screenToolBar }
        }
    }

    private var screenToolBar: some ToolbarContent {
        Group {
            ToolbarItem(placement: .navigationBarLeading) {
                HStack {
                    Button("Close") {
                        copyButtonTitle = "Copy"
                        model.generatedConcept = ""
                        dismiss()
                    }
                    if !model.generatedConcept.isEmpty {
                        Button("Reset") {
                            copyButtonTitle = "Copy"
                            model.generatedConcept = ""
                        }
                    }
                }
            } // ToolbarItem

            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Generate") {
                    copyButtonTitle = "Copy"
                    Task {
                        await model.makeConcept()
                    }
                }.disabled(model.isThinking)
            } // ToolbarItem
        } // Group
    } // screenToolBar
}

struct ConceptView_Previews: PreviewProvider {
    static var previews: some View {
        ConceptView().environmentObject(AppModel())
    }
}
