
import SwiftUI
import AVFoundation
import AVKit
import MetalKit
import AppKit



struct Screen: NSViewControllerRepresentable {
    
    typealias NSViewControllerType = ScreenViewController
    
    
    func updateNSViewController(_ nsViewController: ScreenViewController, context: Context) {
        print("something change")
    }
    
    
    func makeNSViewController(context: Context) -> ScreenViewController {
        return ScreenViewController()
    }
    
}

struct ContentView: View {
    @State private var bufferQueue: Array<CMSampleBuffer> = []
    private let player = AVPlayer()
    var body: some View {
        Screen()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .onAppear {
            
            }
    }
}
