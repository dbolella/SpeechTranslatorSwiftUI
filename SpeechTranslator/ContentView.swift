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
                    .truncationMode(.head)
                    .lineLimit(4)
                    .padding()
            }
            .frame(width: 350, height: 200)
            .background(Color.red.opacity(0.25))
            .padding()
            
            HStack {
                Text(self.closedCap.translation)
                    .font(.body)
                    .truncationMode(.head)
                    .lineLimit(4)
                    .padding()
            }
            .frame(width: 350, height: 200)
            .background(Color.blue.opacity(0.25))
            .padding()
            
            Button(action: {
                self.closedCap.micButtonTapped()
            }) {
                Image(systemName: !self.closedCap.micEnabled ? "mic.slash" : (self.closedCap.isPlaying ? "mic.circle.fill" : "mic.circle"))
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 75)
                    .padding()
            }
        }
        .onAppear {
            self.closedCap.getPermission()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.colorScheme, .dark)
    }
}
