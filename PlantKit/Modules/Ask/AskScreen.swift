//
//  AskScreen.swift
//  PlantKit
//
//  Created by Khuong Pham on 13/6/25.
//

import SwiftUI

struct AskScreen: View {
    @EnvironmentObject var conversationManager: ConversationManager
    @EnvironmentObject var askRouter: Router<ContentRoute>
    @State private var showInbox = false

    var body: some View {
        ZStack {
            Color.appScreenBackgroundColor
                .edgesIgnoringSafeArea(.all)
            content
        }
    }
    
    private var content: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Beautiful Header
                BeautifulHeader {
                    Haptics.shared.play()
                    askRouter.navigate(to: .conversation(.init()))
                }

                // Inbox Section
                VStack(alignment: .leading, spacing: 0) {
                    Text("My Inbox")
                        .font(.title2).bold()
                        .padding(.bottom)
                    Divider()
                    if conversationManager.conversations.isEmpty {
                        EmptyInboxView()
                            .frame(maxHeight: .infinity)
                    } else {
                        conversationList
                    }
                    Spacer()
                }
                .padding()
                .frame(maxHeight: .infinity)
                .background(Color.white)
                
                Spacer()
            }
        }
    }

    private var conversationList: some View {
        VStack(spacing: 0) {
            ForEach(conversationManager.conversations) { conversation in
                Button {
                    askRouter.navigate(to: .conversation(conversation.id))
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(conversation.title)
                                .font(.headline)
                                .foregroundColor(.primary)

                            if let lastMessage = conversation.messages.last {
                                Text(lastMessage.content)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                            }
                        }

                        Spacer()

                        Text(conversation.lastMessageDate, style: .time)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                }
                .buttonStyle(PlainButtonStyle())

                if conversation.id != conversationManager.conversations.last?.id {
                    Divider()
                        .padding(.leading)
                }
            }
        }
    }
}

// MARK: - Beautiful Header

struct BeautifulHeader: View {
    var onContinue: () -> Void
    var body: some View {
        VStack(spacing: 16) {
            Image("bg-ask")
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
                .cornerRadius(16)
            VStack(spacing: 4) {
                Text("Ask Botanist")
                    .font(.largeTitle).bold()
                Text("Get expert plant advice instantly, powered by AI, trusted by botanists.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
            }
            Button(action: onContinue) {
                Text("Ask New Question")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .clipShape(.capsule)
            }
            .padding(.horizontal)
        }
        .padding(.vertical)
        .background(Color.appScreenBackgroundColor)
    }
}

// MARK: - Empty Inbox

struct EmptyInboxView: View {
    var body: some View {
        VStack(spacing: 12) {
            Spacer()
            Image("ic-chat")
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
                .foregroundColor(.secondary.opacity(0.3))
            Text("No Chats")
                .font(.title3).bold()
            Text("As you talk with AI, your conversations will appear here.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    AskScreen()
        .environmentObject(ConversationManager())
        .environmentObject(Router<ContentRoute>())
}
