import UIKit
import Social
import CoreServices
import UniformTypeIdentifiers

class ShareViewController: UIViewController {

    private let typeText = UTType.text
    private let typeURL = UTType.url
    private var appURLString = "cyberme://go?url="

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Get the all encompasing object that holds whatever was shared. If not, dismiss view.
        guard let extensionItem = extensionContext?.inputItems.first as? NSExtensionItem,
            let itemProvider = extensionItem.attachments?.first else {
                self.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
                return
        }

        // Check if object is of type text
        if itemProvider.hasItemConformingToTypeIdentifier(typeText.description) {
            handleIncomingText(itemProvider: itemProvider)
        // Check if object is of type URL
        } else if itemProvider.hasItemConformingToTypeIdentifier(typeURL.description) {
            handleIncomingURL(itemProvider: itemProvider)
        } else {
            print("Error: No url or text found")
            self.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
        }
    }

    private func handleIncomingText(itemProvider: NSItemProvider) {
        itemProvider.loadItem(forTypeIdentifier: typeText.description, options: nil) { (item, error) in
            if let error = error {
                print("Text-Error: \(error.localizedDescription)")
            }

            if let text = item as? String {
                do {
                    // Detect URLs in String
                    let detector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
                    let matches = detector.matches(
                        in: text,
                        options: [],
                        range: NSRange(location: 0, length: text.utf16.count)
                    )
                    // Get first URL found
                    if let firstMatch = matches.first, let range = Range(firstMatch.range, in: text) {
                        print(text[range])
                        self.appURLString += text[range]
                        self.openMainApp()
                    }
                } catch let error {
                    print("Do-Try Error: \(error.localizedDescription)")
                }
            }

            self.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
        }
    }

    private func handleIncomingURL(itemProvider: NSItemProvider) {
        itemProvider.loadItem(forTypeIdentifier: typeURL.description, options: nil) { (item, error) in
            if let error = error {
                print("URL-Error: \(error.localizedDescription)")
            }

            if let url = item as? NSURL, let urlString = url.absoluteString {
                print(urlString)
                self.appURLString += urlString
                self.openMainApp()
            }

            self.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
        }
    }
    
    private func openMainApp() {
        self.extensionContext?.completeRequest(returningItems: nil, completionHandler: { _ in
            guard let url = URL(string: self.appURLString) else { return }
            _ = self.openURL(url)
        })
    }
    
    // Courtesy: https://stackoverflow.com/a/44499222/13363449 👇🏾
    // Function must be named exactly like this so a selector can be found by the compiler!
    // Anyway - it's another selector in another instance that would be "performed" instead.
    @objc func openURL(_ url: URL) -> Bool {
        var responder: UIResponder? = self
        while responder != nil {
            if let application = responder as? UIApplication {
                return application.perform(#selector(openURL(_:)), with: url) != nil
            }
            responder = responder?.next
        }
        return false
    }
}
