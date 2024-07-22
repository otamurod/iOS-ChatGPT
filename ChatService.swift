//
//  ChatService.swift
//  iOS ChatGPT
//
//  Created by Otamurod Safarov on 22/07/24.
//

import GoogleGenerativeAI
import SwiftUI

@Observable
class ChatService {
    var proModel = GenerativeModel(name: "gemini-pro", apiKey: APIKey.default)
    var proVisionModel = GenerativeModel(name: "gemini-pro-vision", apiKey: APIKey.default)
    private(set) var messages = [ChatMessage]()
    private(set) var loadingResponse = false

    func sendMessage(message: String, imageData: [Data]) async {
        loadingResponse = true

        // MARK: add user message & a placeholder AI model message to the list

        messages.append(.init(role: .user, message: message, images: imageData))
        messages.append(.init(role: .model, message: "", images: nil))

        do {
            let chatModel = imageData.isEmpty ? proModel : proVisionModel

            var images = [ThrowingPartsRepresentable]()

            for data in imageData {
                // compressing image since max allowed size approx. 4MB
                if let compressedData = UIImage(data: data)?.jpegData(compressionQuality: 0.1) {
                    images.append(ModelContent.Part.jpeg(compressedData))
                }
            }

            // MARK: Request and stream the response

            let outputStream: AsyncThrowingStream<GenerateContentResponse, Error>
            if images.isEmpty {
                outputStream = chatModel.generateContentStream(message)
            } else {
                outputStream = chatModel.generateContentStream(message, images)
            }

            for try await chunk in outputStream {
                guard let text = chunk.text else {
                    return
                }
                let lastChatMessageIndex = messages.count - 1
                messages[lastChatMessageIndex].message += text
            }
            loadingResponse = false
        } catch {
            loadingResponse = false
            messages.removeLast()
            messages.append(.init(role: .model, message: "Something went wrong. Please try again!"))
            print(error.localizedDescription)
        }
    }
}
