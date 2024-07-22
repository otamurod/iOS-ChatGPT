//
//  NewChatView.swift
//  iOS ChatGPT
//
//  Created by Otamurod Safarov on 16/07/24.
//

import SwiftUI

struct NewChatView: View {
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
                        if model.isNewChatScreenEmpty, !model.newChatEntryText.isEmpty {
                            Text("Tap 'Send' on the Top-Right corner of the screen")
                                .font(.system(size: 18))
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .padding()
                        }

                        if model.isThinking {
                            VStack {
                                Text("Generating response...")
                                ProgressView().progressViewStyle(.circular)
                            }
                        }

                        if model.hasResultNewChatScreen {
                            ResultView(generatedText: model.generatedNewChat).task {
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
                            text: $model.newChatEntryText,
                            axis: .vertical
                        )
                        .focused($isFieldFocused)
                        .padding(8)
                        .background(
                            Color(.secondarySystemFill).cornerRadius(10)
                        )
                        .padding(.leading, 24)

                        if model.newChatEntryText.isEmpty {
                            Button("Paste") {
                                model.newChatEntryText = UIPasteboard.general.string ?? ""
                            }
                        }
                    } // HStack
                    .padding(.trailing, 24)

                    Text("Provide text")
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 34)
                } // VStack
            } // outer VStack
            .navigationTitle("New Chat")
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
                    if !model.generatedNewChat.isEmpty {
                        Button("Reset") {
                            stopLoadingAnimation()

                            model.newChatEntryText = ""
                            model.generatedNewChat = ""
                        }
                    }
                }
            } // ToolbarItem

            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Send") {
                    startLoadingAnimation()
                    Task {
                        await model.makeNewChat()
                    }
                }.disabled(model.isThinking || model.newChatEntryText.isEmpty)
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

struct NewChatView_Previews: PreviewProvider {
    static var previews: some View {
        NewChatView().environmentObject(AppModel())
    }
}
