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
    @State private var conversationToDelete: ChatConversation?
    @State private var showDeleteConfirmation = false

    var body: some View {
        ZStack {
            Color.appScreenBackgroundColor
                .edgesIgnoringSafeArea(.all)
            content
        }
        .onAppear {
            conversationManager.refreshConversations()
        }
        .alert("Delete Conversation", isPresented: $showDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                if let conversation = conversationToDelete {
                    conversationManager.deleteConversation(conversation.id)
                }
                conversationToDelete = nil
            }
            Button("Cancel", role: .cancel) {
                conversationToDelete = nil
            }
        } message: {
            Text("Are you sure you want to delete this conversation? This action cannot be undone.")
        }
    }
    
    private var content: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Beautiful Header
                BeautifulHeader()

                // Inbox Section
                VStack(alignment: .leading, spacing: 0) {
                    Text("My Inbox")
                        .font(.system(size: 22)).bold()
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
                    askRouter.navigate(to: .conversation(conversation.id, nil))
                } label: {
                    HStack(alignment: .top) {
                        Image("ic-tool-ask")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 46, height: 46)
                            .clipShape(Circle())
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(conversation.title)
                                .font(.system(size: 17).weight(.semibold))
                                .foregroundColor(.primary)
                                .lineLimit(1)

                            if let lastMessage = conversation.messages.last {
                                Text(lastMessage.content)
                                    .font(.system(size: 15))
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                            }
                        }

                        Spacer()

                        Text(formatRelativeDate(conversation.lastMessageDate))
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                }
                .buttonStyle(PlainButtonStyle())
                .contextMenu {
                    Button(role: .destructive) {
                        conversationToDelete = conversation
                        showDeleteConfirmation = true
                    } label: {
                        Label("Delete Conversation", systemImage: "trash")
                    }
                }

                if conversation.id != conversationManager.conversations.last?.id {
                    Divider()
                        .padding(.leading)
                }
            }
        }
    }
    
    private func formatRelativeDate(_ date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()
        
        if calendar.isDate(date, inSameDayAs: now) {
            // Today - show time
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            return formatter.string(from: date)
        } else if calendar.isDate(date, inSameDayAs: calendar.date(byAdding: .day, value: -1, to: now) ?? now) {
            // Yesterday
            return "Yesterday"
        } else {
            // Other days - show full date
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            return formatter.string(from: date)
        }
    }
}

// MARK: - Beautiful Header

struct BeautifulHeader: View {
    @EnvironmentObject var conversationManager: ConversationManager
    @EnvironmentObject var askRouter: Router<ContentRoute>
    @ObservedObject var proManager: ProManager = .shared
    
    var body: some View {
        VStack(spacing: 16) {
            Image("bg-ask")
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
                .cornerRadius(16)
            VStack(spacing: 4) {
                Text("Ask Botanist")
                    .font(.system(size: 34)).bold()
                Text("Get expert plant advice instantly, powered by AI, trusted by botanists.")
                    .font(.system(size: 17))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
            }
            Button(action: {
                Haptics.shared.play()
                if proManager.hasPro {
                    let newConversation = conversationManager.createNewConversation()
                    askRouter.navigate(to: .conversation(newConversation.id, nil))
                } else {
                    proManager.showUpgradeProIfNeeded()
                }
            }) {
                Text("Ask New Question")
                    .font(.system(size: 17).weight(.semibold))
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
                .font(.system(size: 20)).bold()
            Text("As you talk with AI, your conversations will appear here.")
                .font(.system(size: 17))
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
