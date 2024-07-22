//
//  MultimodalChatView.swift
//  iOS ChatGPT
//
//  Created by Otamurod Safarov on 22/07/24.
//

import PhotosUI
import SwiftUI

struct MultimodalChatView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var textInput = ""
    @State private var chatService = ChatService()
    @State private var photoPickerItems = [PhotosPickerItem]()
    @State private var selectedPhotoData = [Data]()

    var body: some View {
        NavigationStack {
            VStack {
                // MARK: Logo

                Image(.geminiLogo)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200)

                // MARK: Chat Message List

                ScrollViewReader(content: { proxy in
                    ScrollView {
                        ForEach(chatService.messages) { chatMessage in

                            // MARK: Chat message view

                            chatMessageView(chatMessage)
                        }
                    }
                    .onChange(of: chatService.messages) {
                        guard let recentMessage = chatService.messages.last else { return }
                        DispatchQueue.main.async {
                            withAnimation {
                                proxy.scrollTo(recentMessage.id, anchor: .bottom)
                            }
                        }
                    }
                })

                // MARK: Image Preview

                if selectedPhotoData.count > 0 {
                    ScrollView(.horizontal) {
                        LazyHStack(spacing: 10, content: {
                            ForEach(0 ..< selectedPhotoData.count, id: \.self) { index in
                                Image(uiImage: UIImage(data: selectedPhotoData[index])!)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 50)
                                    .clipShape(RoundedRectangle(cornerRadius: 5.0))
                            }
                        })
                    }.frame(height: 50)
                }

                // MARK: Input fields

                HStack {
                    PhotosPicker(selection: $photoPickerItems, maxSelectionCount: 3, matching: .images) {
                        Image(systemName: "photo.stack.fill").frame(width: 40, height: 25)
                    }
                    .onChange(of: photoPickerItems) {
                        Task {
                            selectedPhotoData.removeAll()

                            for item in photoPickerItems {
                                if let imageData = try await item.loadTransferable(type: Data.self) {
                                    selectedPhotoData.append(imageData)
                                }
                            }
                        }
                    }

                    TextField("Enter a message...", text: $textInput)
                        .textFieldStyle(.roundedBorder)

                    if chatService.loadingResponse {
                        ProgressView()
                            .tint(.white)
                            .frame(width: 30)
                    } else {
                        Button(action: sendMessage, label: {
                            Image(systemName: "paperplane.fill")
                        }).frame(width: 30)
                    }
                }
            }
            .foregroundStyle(.blue)
            .padding()
            .navigationTitle("Multi-Modal Chat")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                } // ToolbarItem
            }
        }
    }

    // MARK: Chat message view

    @ViewBuilder private func chatMessageView(_ message: ChatMessage) -> some View {
        // MARK: Chat image display

        if let images = message.images, !images.isEmpty {
            ScrollView(.horizontal) {
                LazyHStack(spacing: 10, content: {
                    ForEach(0 ..< images.count, id: \.self) { index in
                        Image(uiImage: UIImage(data: images[index])!)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 150)
                            .clipShape(RoundedRectangle(cornerRadius: 5.0))
                            .containerRelativeFrame(.horizontal)
                    }
                })
                .scrollTargetLayout()
            }
            .frame(height: 150)
        }

        // MARK: Chat message buble

        ChatBubble(direction: message.role == .model ? .left : .right) {
            Text(message.message)
                .font(.title3)
                .padding(.all, 20)
                .foregroundStyle(.white)
                .background(message.role == .model ? Color.blue : Color.green)
        }
    }

    // MARK: Fetch Response

    private func sendMessage() {
        Task {
            await chatService.sendMessage(message: textInput, imageData: selectedPhotoData)

            selectedPhotoData.removeAll()
            textInput = ""
        }
    }
}

struct MultimodalChatView_Previews: PreviewProvider {
    static var previews: some View {
        MultimodalChatView()
    }
}
