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
    @Environment(AuthManager.self) private var authManager
    @Environment(UsageManager.self) private var usageManager
    @Environment(SubscriptionManager.self) private var subscriptionManager
    
    @AppStorage("colorSchemePreference") private var colorSchemePreference: ColorSchemePreference = .automatic
    @AppStorage("notificationPreference") private var notificationPreference: Bool = true
    
    @State private var showSubscriptionSheet: Bool = false
    @State private var showLogoutConfirmation: Bool = false

    var body: some View {
        NavigationStack {
            List {
                Section("Account") {
                    LabeledContent {
                        Text(authManager.email ?? "")
                            .foregroundStyle(.secondary)
                    } label: {
                        Label("Email", systemImage: "envelope")
                    }
                    
                    LabeledContent {
                        Text(subscriptionManager.tier.displayName)
                    } label: {
                        Label("Subscription", systemImage: "plus.circle")
                    }
                    .onTapGesture {
                        showSubscriptionSheet = true
                    }
                    
                    NavigationLink {
                        List {
                            LabeledContent("Podcasts", value: usageManager.usage(for: .podcast))
                            LabeledContent("Daily Episodes", value: usageManager.usage(for: .episode))
                            LabeledContent("Daily Extended Episodes", value: usageManager.usage(for: .extendedEpisode))
                        }
                        .refreshable { await usageManager.refresh() }
                        .task { await usageManager.refresh() }
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
                
                Button(action: { showLogoutConfirmation = true }) {
                    Label("Log out", systemImage: "rectangle.portrait.and.arrow.right")
                }
                .foregroundStyle(.red)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showSubscriptionSheet) { SubscriptionView() }
            .confirmationDialog("Log Out", isPresented: $showLogoutConfirmation) {
                Button("Log Out", role: .destructive) {
                    do {
                        try context.delete(model: Podcast.self)
                        try context.save()
                        
                        try authManager.signOut()
                    } catch {
                        print("Logout failed: \(error)")
                    }
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Are you sure you want to log out?")
            }
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
