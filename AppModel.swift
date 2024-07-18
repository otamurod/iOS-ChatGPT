//
//  AppModel.swift
//  iOS ChatGPT
//
//  Created by Otamurod Safarov on 16/07/24.
//

import GoogleGenerativeAI
import SwiftUI

// @final keyword means that the class cannot be inherited
final class AppModel: ObservableObject {
    // MARK: Gemini AI

    let model = GenerativeModel(name: "gemini-pro", apiKey: APIKey.default)
    private let defaultGreeting = "Hello! How can I help you today?"

    @Published var isThinking: Bool = false
    @Published var selectedModule: Modules?
    var textInput = ""

    // MARK: Settings

    private let displayModeKey = "displayMode"
    @Published var displayMode: String {
        didSet {
            UserDefaults.standard.set(displayMode, forKey: displayModeKey)
        }
    }

    // MARK: New Chat

    @Published var newChatEntryText: String = ""
    @Published var generatedNewChat: String
    var isNewChatScreenEmpty: Bool { !isThinking && generatedNewChat.isEmpty }
    var hasResultNewChatScreen: Bool { !isThinking && !generatedNewChat.isEmpty }

    // MARK: Random Concept

    @Published var generatedConcept = ""
    var isConceptScreenEmpty: Bool { !isThinking && generatedConcept.isEmpty }
    var hasResultConceptScreen: Bool { !isThinking && !generatedConcept.isEmpty }

    // MARK: Related Topics

    @Published var relatedTopicsEntryText: String = ""
    @Published var generatedRelatedTopics: String
    var isRelatedTopicsScreenEmpty: Bool { !isThinking && generatedRelatedTopics.isEmpty }
    var hasResultRelatedTopicsScreen: Bool { !isThinking && !generatedRelatedTopics.isEmpty }

    // MARK: Definition

    @Published var definitionEntryText: String = ""
    @Published var generatedDefinition: String
    var isDefinitionScreenEmpty: Bool { !isThinking && generatedDefinition.isEmpty }
    var hasResultDefinitionScreen: Bool { !isThinking && !generatedDefinition.isEmpty }

    // MARK: Article

    @Published var articleEntryText: String = ""
    @Published var generatedArticle: String
    var isArticleScreenEmpty: Bool { !isThinking && generatedArticle.isEmpty }
    var hasResultArticleScreen: Bool { !isThinking && !generatedArticle.isEmpty }

    // MARK: Expand Text

    @Published var expandedEntryText: String = ""
    @Published var generatedExpandedText: String
    var isExpandedTextScreenEmpty: Bool { !isThinking && generatedExpandedText.isEmpty }
    var hasResultExpandedTextScreen: Bool { !isThinking && !generatedExpandedText.isEmpty }

    // MARK: Summarize Text

    @Published var summarizedEntryText: String = ""
    @Published var generatedSummarizedText: String
    var isSummarizedTextScreenEmpty: Bool { !isThinking && generatedSummarizedText.isEmpty }
    var hasResultSummarizedTextScreen: Bool { !isThinking && !generatedSummarizedText.isEmpty }

    // MARK: Comparison

    @Published var differenceEntryText1: String = ""
    @Published var differenceEntryText2: String = ""
    @Published var generatedComparison: String
    var isComparisonScreenEmpty: Bool { !isThinking && generatedComparison.isEmpty }
    var hasResultComparisonScreen: Bool { !isThinking && !generatedComparison.isEmpty }

    // MARK: Next

    @Published var generatedNext = ""
    var isNextScreenEmpty: Bool { !isThinking && generatedNext.isEmpty }
    var hasResultNextScreen: Bool { !isThinking && !generatedNext.isEmpty }

    // MARK: Affirmation

    @Published var generatedAffirmation = ""
    var isAffirmationScreenEmpty: Bool { !isThinking && generatedAffirmation.isEmpty }
    var hasResultAffirmationScreen: Bool { !isThinking && !generatedAffirmation.isEmpty }

    init() {
        self.displayMode = UserDefaults.standard.string(forKey: displayModeKey) ?? "System"

        self.generatedNewChat = defaultGreeting
        self.generatedRelatedTopics = defaultGreeting
        self.generatedDefinition = defaultGreeting
        self.generatedArticle = defaultGreeting
        self.generatedExpandedText = defaultGreeting
        self.generatedSummarizedText = defaultGreeting
        self.generatedComparison = defaultGreeting
    }

    func makeNewChat() async {
        sendMessage(input: newChatEntryText)
    }

    func makeConcept() async {
        textInput = "Generate a concept, generally a word or many, in the realm of anything, that is grounded in reality, and that may or may not be valuable to learn about. Simply provide the short concept without punctuation."

        sendMessage(input: textInput)
    }

    func makeReletadTopics() async {
        textInput = "Generate 5 topics that are closely related to \(relatedTopicsEntryText). Simply provide the related topics seperated by new line."

        sendMessage(input: textInput)
    }

    func makeDefinition() async {
        textInput = "Provide the definition of \(definitionEntryText)."

        sendMessage(input: textInput)
    }

    func makeArticle() async {
        textInput = "Generate an in-depth, grounded in reality, 1 paragraph wikipedia article for a reader who does not understand the topic of \(articleEntryText). Simply provide the generated article."

        sendMessage(input: textInput)
    }

    func makeExpanded() async {
        textInput = "Expand on the following text: \(expandedEntryText)"

        sendMessage(input: textInput)
    }

    func makeSummary() async {
        textInput = "Summarize the following text, readable by 8th grader: \(summarizedEntryText)"

        sendMessage(input: textInput)
    }

    func makeComparison() async {
        textInput = "Provide a list of differences between: \(differenceEntryText1) and \(differenceEntryText2)"

        sendMessage(input: textInput)
    }

    func makeNext() async {
        textInput = "Provide a random but important, single thing to think about on the topic of daily living, in the form of a direction for me to follow right now. Be specific."

        sendMessage(input: textInput)
    }

    func makeAffirmation() async {
        textInput = "Provide an affirmation I can tell myself that will subtly fill me with life and smiles and that is not too confusing. Provide the affirmation without quotes."

        sendMessage(input: textInput)
    }

    // MARK: Gemini AI model

    func sendMessage(input: String) {
        clearInputsAndOutputs()

        Task {
            do {
                let response = try await model.generateContent(input)

                let text = response.text ?? "Sorry, I could not process that.\nPlease try again."

                DispatchQueue.main.async {
                    self.isThinking = false
                }

                switch selectedModule {
                case .newChat: DispatchQueue.main.async {
                        self.generatedNewChat = text
                    }
                case .randomConcept: DispatchQueue.main.async {
                        self.generatedConcept = text
                    }
                case .relatedTopics: DispatchQueue.main.async {
                        self.generatedRelatedTopics = text
                    }
                case .definition: DispatchQueue.main.async {
                        self.generatedDefinition = text
                    }
                case .article: DispatchQueue.main.async {
                        self.generatedArticle = text
                    }
                case .expanded: DispatchQueue.main.async {
                        self.generatedExpandedText = text
                    }
                case .summarized: DispatchQueue.main.async {
                        self.generatedSummarizedText = text
                    }
                case .comparison: DispatchQueue.main.async {
                        self.generatedComparison = text
                    }
                case .next: DispatchQueue.main.async {
                        self.generatedNext = text
                    }
                case .affirmation: DispatchQueue.main.async {
                        self.generatedAffirmation = text
                    }
                case .none: break
                }

            } catch {
                DispatchQueue.main.async {
                    self.isThinking = false
                }
                let errorMessage = "Something went wrong!\n\(error.localizedDescription)"

                switch selectedModule {
                case .newChat: DispatchQueue.main.async {
                        self.generatedNewChat = errorMessage
                    }
                case .randomConcept: DispatchQueue.main.async {
                        self.generatedConcept = errorMessage
                    }
                case .relatedTopics: DispatchQueue.main.async {
                        self.generatedRelatedTopics = errorMessage
                    }
                case .definition: DispatchQueue.main.async {
                        self.generatedDefinition = errorMessage
                    }
                case .article: DispatchQueue.main.async {
                        self.generatedArticle = errorMessage
                    }
                case .expanded: DispatchQueue.main.async {
                        self.generatedExpandedText = errorMessage
                    }
                case .summarized: DispatchQueue.main.async {
                        self.generatedSummarizedText = errorMessage
                    }
                case .comparison: DispatchQueue.main.async {
                        self.generatedComparison = errorMessage
                    }
                case .next: DispatchQueue.main.async {
                        self.generatedNext = errorMessage
                    }
                case .affirmation: DispatchQueue.main.async {
                        self.generatedAffirmation = errorMessage
                    }
                case .none: break
                }
            }
        }
    }

    func clearInputsAndOutputs() {
        DispatchQueue.main.async {
            self.generatedNewChat = ""
            self.newChatEntryText = ""

            self.generatedConcept = ""

            self.relatedTopicsEntryText = ""
            self.generatedRelatedTopics = ""

            self.definitionEntryText = ""
            self.generatedDefinition = ""

            self.articleEntryText = ""
            self.generatedArticle = ""

            self.expandedEntryText = ""
            self.generatedExpandedText = ""

            self.summarizedEntryText = ""
            self.generatedSummarizedText = ""

            self.differenceEntryText1 = ""
            self.differenceEntryText2 = ""
            self.generatedComparison = ""

            self.generatedNext = ""
            self.generatedAffirmation = ""

            self.textInput = ""
            self.isThinking = true
        }
    }
}

// MARK: Modules

enum Modules: CaseIterable, Identifiable {
    case newChat
    case randomConcept
    case relatedTopics
    case definition
    case article
    case expanded
    case summarized
    case comparison
    case next
    case affirmation

    var id: String { return title }
    var title: String {
        switch self {
        case .newChat: return "New Chat"
        case .randomConcept: return "Random Concept"
        case .relatedTopics: return "Related Topics"
        case .definition: return "Definition"
        case .article: return "Article"
        case .expanded: return "Expand Text"
        case .summarized: return "Summarize Text"
        case .comparison: return "Comparison"
        case .next: return "Next"
        case .affirmation: return "Affirmation"
        }
    }

    var sfSymbol: String {
        switch self {
        case .newChat: return "text.bubble"
        case .randomConcept: return "lightbulb"
        case .relatedTopics: return "square.stack.3d.up"
        case .definition: return "exclamationmark.circle"
        case .article: return "book"
        case .expanded: return "plus"
        case .summarized: return "minus"
        case .comparison: return "arrow.up.arrow.down"
        case .next: return "arrowshape.right"
        case .affirmation: return "checkmark.seal"
        }
    }
}
