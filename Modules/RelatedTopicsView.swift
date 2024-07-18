//
//  RelatedTopicsView.swift
//  iOS ChatGPT
//
//  Created by Otamurod Safarov on 17/07/24.
//

import SwiftUI

struct RelatedTopicsView: View {
    @EnvironmentObject private var model: AppModel
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isFieldFocused: Bool
    @State var logoAnimating = false
    @State private var timer: Timer?

    var body: some View {
        NavigationStack {
            VStack {
                // MARK: Animating logo

                Image(.geminiLogo)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200)
                    .opacity(logoAnimating ? 0.5 : 1)
                    .animation(.easeInOut, value: logoAnimating)

                // MARK: AI response

                ScrollView {
                    VStack(spacing: 34) {
                        if model.isRelatedTopicsScreenEmpty, !model.relatedTopicsEntryText.isEmpty {
                            Text("Tap 'Generate' on the Top-Right corner of the screen")
                                .font(.system(size: 18))
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .padding()
                        }

                        if model.isThinking {
                            VStack {
                                Text("Generating related topics...")
                                ProgressView().progressViewStyle(.circular)
                            }
                        }

                        if model.hasResultRelatedTopicsScreen {
                            ResultView(generatedText: model.generatedRelatedTopics).task {
                                stopLoadingAnimation()
                            }
                        }
                    } // VStack
                } // ScrollView
                .scrollDismissesKeyboard(.immediately)

                // MARK: Input fields

                VStack {
                    HStack {
                        TextField(
                            "Required",
                            text: $model.relatedTopicsEntryText,
                            axis: .vertical
                        )
                        .focused($isFieldFocused)
                        .padding(8)
                        .background(
                            Color(.secondarySystemFill).cornerRadius(10)
                        )
                        .padding(.leading, 24)

                        if model.relatedTopicsEntryText.isEmpty {
                            Button("Paste") {
                                model.relatedTopicsEntryText = UIPasteboard.general.string ?? ""
                            }
                        }
                    } // HStack
                    .padding(.trailing, 24)

                    Text("Provide text to create related topics")
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 34)
                } // VStack
            } // outer VStack
            .navigationTitle("Related Topics")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                screenToolBar
            } // toolbar
        }
    }

    private var screenToolBar: some ToolbarContent {
        Group {
            ToolbarItem(placement: .navigationBarLeading) {
                HStack {
                    Button("Close") {
                        dismiss()
                    }
                    if !model.generatedRelatedTopics.isEmpty {
                        Button("Reset") {
                            stopLoadingAnimation()

                            model.relatedTopicsEntryText = ""
                            model.generatedRelatedTopics = ""
                        }
                    }
                }
            } // ToolbarItem

            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Generate") {
                    startLoadingAnimation()
                    Task {
                        await model.makeReletadTopics()
                    }
                }.disabled(model.isThinking || model.relatedTopicsEntryText.isEmpty)
            } // ToolbarItem
        } // Group
    } // screenToolBar

    // MARK: Response loading animation

    func startLoadingAnimation() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true, block: { _ in
            logoAnimating.toggle()
        })
    }

    func stopLoadingAnimation() {
        logoAnimating = false
        timer?.invalidate()
        timer = nil
    }
}

struct RelatedTopicsView_Previews: PreviewProvider {
    static var previews: some View {
        RelatedTopicsView().environmentObject(AppModel())
    }
}
