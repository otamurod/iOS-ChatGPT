//
//  ArticleView.swift
//  iOS ChatGPT
//
//  Created by Otamurod Safarov on 17/07/24.
//

import SwiftUI

struct ArticleView: View {
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
                        if model.isArticleScreenEmpty, !model.articleEntryText.isEmpty {
                            Text("Tap 'Generate' on the Top-Right corner of the screen")
                                .font(.system(size: 18))
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .padding()
                        }

                        if model.isThinking {
                            VStack {
                                Text("Generating article...")
                                ProgressView().progressViewStyle(.circular)
                            }
                        }

                        if model.hasResultArticleScreen {
                            ResultView(generatedText: model.generatedArticle).task {
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
                            text: $model.articleEntryText,
                            axis: .vertical
                        )
                        .focused($isFieldFocused)
                        .padding(8)
                        .background(
                            Color(.secondarySystemFill).cornerRadius(10)
                        )
                        .padding(.leading, 24)

                        if model.articleEntryText.isEmpty {
                            Button("Paste") {
                                model.articleEntryText = UIPasteboard.general.string ?? ""
                            }
                        }
                    } // HStack
                    .padding(.trailing, 24)

                    Text("Provide a topic or keyword to write an article")
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 34)
                } // VStack
            } // outer VStack
            .navigationTitle("Article")
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
                    if !model.generatedArticle.isEmpty {
                        Button("Reset") {
                            stopLoadingAnimation()

                            model.articleEntryText = ""
                            model.generatedArticle = ""
                        }
                    }
                }
            } // ToolbarItem

            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Generate") {
                    startLoadingAnimation()
                    Task {
                        await model.makeArticle()
                    }
                }.disabled(model.isThinking || model.articleEntryText.isEmpty)
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

struct ArticleView_Previews: PreviewProvider {
    static var previews: some View {
        ArticleView().environmentObject(AppModel())
    }
}
