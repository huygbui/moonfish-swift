//
//  RequestCardMenu.swift
//  moonfish
//
//  Created by Huy Bui on 13/6/25.
//

import SwiftUI

struct RequestCardMenu: View {
    var request : PodcastRequest
    @Environment(RequestViewModel.self) private var rootModel
    @State private var showingAlert: Bool = false
    
    var body: some View {
        Menu {
            Button(role: .destructive, action: { showingAlert = true}) {
                Label ("Stop", systemImage: "xmark")
            }
        } label: {
            Image(systemName: "ellipsis")
                .font(.footnote)
                .frame(width: 24, height: 24)
                .background(Color(.tertiarySystemBackground), in: .circle)
        }
        .alert("Stop Request?", isPresented: $showingAlert) {
            Button("Don't Stop", role: .cancel) { }
            Button("Stop", role: .destructive) {
                Task {
                    await rootModel.cancel(request)
                }
            }
        } message: {
            Text("Stopping now will still count towards as one request.")
        }
    }
}

#Preview {
    RequestCardMenu(request: .preview)
        .environment(RequestViewModel())
}
