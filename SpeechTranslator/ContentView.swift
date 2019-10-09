//
//  ContentView.swift
//  SpeechTranslator
//
//  Created by Daniel Bolella on 10/9/19.
//  Copyright © 2019 Daniel Bolella. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var closedCap = ClosedCaptioning()
    
    var body: some View {
        VStack {
            HStack {
                Text(self.closedCap.captioning)
                    .font(.body)
                    .foregroundColor(Color.white)
                    .truncationMode(.head)
                    .lineLimit(1)
                    .padding()
            }
            .background(Color.black.opacity(0.75))
            
            Button(action: {
                self.closedCap.micButtonTapped()
            }) {
                Image(systemName: !self.closedCap.micEnabled ? "mic.slash" : (self.closedCap.isPlaying ? "mic.circle.fill" : "mic.circle"))
                    .font(.largeTitle)
            }
        }
        .onAppear {
            self.closedCap.getPermission()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
