//
//  Account.swift
//  moonfish
//
//  Created by Huy Bui on 13/6/25.
//

import SwiftUI

struct AccountSheet: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Account Sheet")
            }
            .navigationTitle("Account")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        
                    } label: {
                        Image(systemName: "checkmark")
                    }
                }
            }
        }
    }
}

#Preview {
    AccountSheet()
}
