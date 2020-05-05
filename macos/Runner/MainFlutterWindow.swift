import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController.init()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    let controller : FlutterViewController = self.contentViewController as! FlutterViewController
    let channel = FlutterMethodChannel(name: "net.hekatoncheir.importPictures/folders",
                                       binaryMessenger: controller.engine.binaryMessenger)
    channel.setMethodCallHandler({
      [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      // Note: this method is invoked on the UI thread.
      guard call.method == "chooseFolder" else {
        result(FlutterMethodNotImplemented)
        return
      }
      self?.chooseFolder(result: result)
        
    })
    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }
    
    
    private func chooseFolder(result: @escaping FlutterResult) {
        let panel : NSOpenPanel = NSOpenPanel.init()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.canCreateDirectories = true
        panel.prompt = ""
        panel.message = ""
        panel.beginSheetModal(for: self, completionHandler:  {
            (panelResult : NSApplication.ModalResponse) -> Void in
                if panelResult.rawValue == NSFileHandlingPanelOKButton {
                    result(panel.url?.path)
                }else{
                    result("")
                }
            
            }
        )
    }
}
