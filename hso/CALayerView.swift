import SwiftUI

struct CALayerView: NSViewControllerRepresentable {
    var caLayer: NSView

    func makeNSViewController(context: NSViewControllerRepresentableContext<CALayerView>) -> NSViewController {
        let viewController = NSViewController()

        viewController.view.layer.addSublayer(caLayer)
        caLayer.frame = viewController.view.layer.frame

        return viewController
    }

    func updateNSViewController(_ uiViewController: NSViewController, context: NSViewControllerRepresentableContext<CALayerView>) {
        caLayer.frame = uiViewController.view.layer.frame
    }
}
