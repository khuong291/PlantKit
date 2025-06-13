//
//  AskScreen.swift
//  PlantKit
//
//  Created by Khuong Pham on 13/6/25.
//

import SwiftUI

struct AskScreen: View {
    @EnvironmentObject var identifierManager: IdentifierManager
    @State private var refreshID = UUID()
    @State private var messageText = ""
    
    var body: some View {
        ZStack {
            Color.appScreenBackgroundColor
                .edgesIgnoringSafeArea(.all)
            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Ask Botanist")
                                .font(.largeTitle)
                                .bold()
                            Spacer()
                        }
                        
                        if identifierManager.recentScans.isEmpty {
                            Spacer()
                            emptyView
                                .frame(maxWidth: .infinity)
                            Spacer()
                        } else {
                            conversationList
                            Spacer()
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, minHeight: UIScreen.main.bounds.height - 100)
                }
                .frame(maxWidth: .infinity)
                
                // Message input bar
                HStack(spacing: 12) {
                    TextField("Ask about your plants...", text: $messageText)
                        .padding(12)
                        .background(Color.white)
                        .cornerRadius(20)
                    
                    Button {
                        // Send message action
                        Haptics.shared.play()
                    } label: {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.green)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color.white)
                .overlay(
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(Color.gray.opacity(0.2)),
                    alignment: .top
                )
            }
        }
        .id(refreshID)
        .onAppear {
            refreshID = UUID()
        }
    }
    
    private var emptyView: some View {
        VStack(spacing: 10) {
            Image(systemSymbol: .bubbleLeftAndBubbleRightFill)
                .font(.title)
                .foregroundStyle(.green)
            Text("No conversations yet. Ask anything about your plants!")
                .foregroundColor(.secondary)
                .font(.footnote)
                .multilineTextAlignment(.center)
        }
    }
    
    private var conversationList: some View {
        VStack(spacing: 16) {
            // Example conversation items
            ChatBubble(
                message: "What's wrong with my Monstera?",
                isUser: true,
                timestamp: Date()
            )
            
            ChatBubble(
                message: "Based on the photo, your Monstera appears to have yellowing leaves which could indicate overwatering. Try reducing the frequency of watering and ensure the soil has good drainage.",
                isUser: false,
                timestamp: Date()
            )
            
            ChatBubble(
                message: "How often should I water it?",
                isUser: true,
                timestamp: Date()
            )
            
            ChatBubble(
                message: "Monstera plants prefer to dry out between waterings. Water when the top 2-3 inches of soil are dry, typically every 1-2 weeks depending on your environment.",
                isUser: false,
                timestamp: Date()
            )
        }
    }
}

struct ChatBubble: View {
    let message: String
    let isUser: Bool
    let timestamp: Date
    
    var body: some View {
        HStack {
            if isUser { Spacer() }
            
            VStack(alignment: isUser ? .trailing : .leading, spacing: 4) {
                Text(message)
                    .padding(12)
                    .background(isUser ? Color.green : Color.white)
                    .foregroundColor(isUser ? .white : .primary)
                    .cornerRadius(16)
                
                Text(timestamp, style: .time)
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            
            if !isUser { Spacer() }
        }
    }
}

#Preview {
    AskScreen().environmentObject(IdentifierManager())
}
