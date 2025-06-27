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

    var body: some View {
        NavigationStack {
            List {
                Text(authManager.email ?? "")
                
                Section {
                    NavigationLink { Text("Profile") } label: {
                        Label("Profile", systemImage: "person.circle")
                    }
                    
                    NavigationLink { Text("Billing") } label: {
                        Label("Billing", systemImage: "dollarsign.circle")
                    }
                }
                
                Section {
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
            .preferredColorScheme(colorSchemePreference.colorScheme)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
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
