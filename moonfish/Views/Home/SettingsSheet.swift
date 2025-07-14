//
//  Account.swift
//  moonfish
//
//  Created by Huy Bui on 13/6/25.
//

import SwiftUI

struct SettingsSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Environment(SessionManager.self) private var sessionManager
    @AppStorage("colorSchemePreference") private var colorSchemePreference: ColorSchemePreference = .automatic
    @AppStorage("notificationPreference") private var notificationPreference: Bool = true
    
    @State private var showSubscriptionSheet: Bool = false

    var body: some View {
        NavigationStack {
            List {
                Section("Account") {
                    LabeledContent {
                        Text(sessionManager.email ?? "user@example.com")
                            .foregroundStyle(.secondary)
                    } label: {
                        Label("Email", systemImage: "envelope")
                    }
                    
                    LabeledContent {
                        Text(sessionManager.subscriptionTier.displayName)
                    } label: {
                        Label("Subscription", systemImage: "plus.circle")
                    }
                    .onTapGesture {
                        showSubscriptionSheet = true
                    }
                    
                    Label("Restore Purchases", systemImage: "arrow.clockwise")
                    
                    NavigationLink {
                        List {
                            LabeledContent("Podcasts", value: sessionManager.usageText(for: .podcast, in: context))
                            LabeledContent("Daily Episodes", value: sessionManager.usageText(for: .episode, in: context))
                            LabeledContent("Daily Extended Episodes", value: sessionManager.usageText(for: .extendedEpisode, in: context))
                        }
                        .navigationTitle("Usage")
                        .navigationBarTitleDisplayMode(.inline)
                        
                    } label: {
                        Label("Usage", systemImage: "gauge.with.needle")
                    }
                }
                
                Section("App") {
                    Toggle(isOn: $notificationPreference) {
                        Label("Notification", systemImage: "bell")
                    }
                    
                    Picker(
                        selection: $colorSchemePreference,
                        label: Label("Appearance", systemImage: "sun.max")
                    ) {
                        ForEach(ColorSchemePreference.allCases, id: \.self) { mode in
                            Text(mode.displayName).tag(mode)
                        }
                    }
                }
                
                Button(action: { sessionManager.signOut(context: context) }) {
                    Label("Log out", systemImage: "rectangle.portrait.and.arrow.right")
                }
                .foregroundStyle(.red)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showSubscriptionSheet) { SubscriptionView() }
            .preferredColorScheme(colorSchemePreference.colorScheme)
            .toolbar {
                ToolbarItem {
                    Button { dismiss() } label: {
                        Label("Dismiss", systemImage: "xmark")
                    }
                }
            }
        }
    }
}



#Preview(traits: .audioPlayerTrait) {
    @Previewable @AppStorage("colorSchemePreference") var colorSchemePreference: ColorSchemePreference = .automatic
    
    SettingsSheet()
        .preferredColorScheme(colorSchemePreference.colorScheme)
}
