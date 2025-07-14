//
//  Account.swift
//  moonfish
//
//  Created by Huy Bui on 13/6/25.
//

import SwiftUI

struct SettingsSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AuthManager.self) private var authManager
    @AppStorage("colorSchemePreference") private var colorSchemePreference: ColorSchemePreference = .automatic
    @AppStorage("notificationPreference") private var notificationPreference: Bool = true
    
    @State private var showSubscriptionSheet: Bool = false

    var body: some View {
        NavigationStack {
            List {
                Section("Account") {
                    LabeledContent {
                        Text(authManager.email ?? "")
                    } label: {
                        Label("Email", systemImage: "envelope")
                    }
                    
                    Label("Subscription", systemImage: "dollarsign.circle")
                        .onTapGesture {
                            showSubscriptionSheet = true
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
                
                Button(action: authManager.signOut) {
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



#Preview {
    @Previewable @AppStorage("colorSchemePreference") var colorSchemePreference: ColorSchemePreference = .automatic
    
    SettingsSheet()
        .environment(AuthManager())
        .preferredColorScheme(colorSchemePreference.colorScheme)
}
