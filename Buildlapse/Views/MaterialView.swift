//
//  MaterialView.swift
//  Buildlapse
//
//  Created by Brian Cao on 2/9/23.
//

import SwiftUI

struct MaterialView: NSViewRepresentable {
    
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.blendingMode = .behindWindow
        return view
    }
    
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {}
}

