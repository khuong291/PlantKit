//
//  AskScreen.swift
//  PlantKit
//
//  Created by Khuong Pham on 13/6/25.
//

import SwiftUI

struct AskScreen: View {
    @EnvironmentObject var conversationManager: ConversationManager
    @State private var showInbox = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // Beautiful Header
                    BeautifulHeader {
                        withAnimation {
                            showInbox = true
                        }
                    }
                    .padding(.top, 32)
                    .padding(.bottom, 24)

                    // Inbox Section
                    VStack(alignment: .leading, spacing: 0) {
                        Text("My Inbox")
                            .font(.title2).bold()
                            .padding(.horizontal)
                            .padding(.bottom, 8)

                        if conversationManager.conversations.isEmpty {
                            EmptyInboxView()
                                .padding(.top, 32)
                        } else {
                            conversationList
                        }
                    }
                    .background(Color.white)
                    .cornerRadius(24)
                    .padding(.horizontal, 0)
                }
                .background(Color(.systemGroupedBackground))
            }
            .navigationBarHidden(true)
        }
    }

    private var conversationList: some View {
        VStack(spacing: 0) {
            ForEach(conversationManager.conversations) { conversation in
                NavigationLink(destination: ConversationScreen(conversationId: conversation.id)) {
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
            ZStack {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color.blue)
                    .frame(width: 100, height: 100)
                Image(systemName: "bubble.left.and.bubble.right.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 56, height: 56)
                    .foregroundColor(.white)
            }
            Text("PlantApp")
                .font(.headline)
                .foregroundColor(.gray)
            Text("Ask Botanist")
                .font(.largeTitle).bold()
            Text("Get expert plant advice instantly—powered by AI, trusted by botanists.")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal, 16)
            Button(action: onContinue) {
                Text("Continue")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(16)
            }
            .padding(.horizontal, 32)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(32)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        .padding(.horizontal)
    }
}

// MARK: - Empty Inbox

struct EmptyInboxView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "plus.bubble")
                .font(.system(size: 40))
                .foregroundColor(.gray)
            Text("No Chats")
                .font(.title3).bold()
            Text("As you talk with AI, your conversations will appear here.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    AskScreen()
        .environmentObject(ConversationManager())
}
