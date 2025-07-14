//
//  SubscriptionView.swift
//  moonfish
//
//  Created by Huy Bui on 13/7/25.
//

import SwiftUI
import StoreKit

struct SubscriptionView: View {
    var body: some View {
        SubscriptionStoreView(groupID: "21731224")
            .storeButton(.hidden)
    }
}

#Preview {
        SubscriptionView()
}
