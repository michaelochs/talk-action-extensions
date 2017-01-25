//
//  ActionViewController.swift
//  Extension-Swift
//
//  Created by Michael Ochs on 1/22/17.
//  Copyright © 2017 PSPDFKit. All rights reserved.
//

import UIKit
import MobileCoreServices

class ActionViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Get the item[s] we're handling from the extension context.

        // For example, look for an image and place it into an image view.
        // Replace this with something appropriate for the type[s] your extension supports.
        var imageFound = false
        for item in self.extensionContext!.inputItems as! [NSExtensionItem] {
            for provider in item.attachments! as! [NSItemProvider] {
                if provider.hasItemConformingToTypeIdentifier(kUTTypeImage as String) {
                    // This is an image. We'll load it, then place it in our image view.
                    weak var weakImageView = self.imageView
                    provider.loadItem(forTypeIdentifier: kUTTypeImage as String, options: nil, completionHandler: { (item, error) in
                        DispatchQueue.main.async {
                            do {
                                if let strongImageView = weakImageView {
                                    if let url = item as? URL {
                                        let target = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent(url.lastPathComponent)
                                        if let exists = try? target.checkResourceIsReachable(), exists == true {
                                            try! FileManager.default.removeItem(at: target)
                                        }
                                        try FileManager.default.copyItem(at: url, to: target)
                                        strongImageView.image = UIImage(contentsOfFile: target.path)
                                    } else if let data = item as? Data {
                                        let target = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent("image")
                                        if let exists = try? target.checkResourceIsReachable(), exists == true {
                                            try! FileManager.default.removeItem(at: target)
                                        }
                                        try data.write(to: target, options: .atomic)
                                        strongImageView.image = UIImage(data: data)
                                    } else {
                                        throw NSError(domain: "unknown", code: -1, userInfo: [NSLocalizedDescriptionKey: "Can not convert to Data"])
                                    }
                                }
                            } catch {
                                self.showError(error as NSError)
                            }
                        }
                    })

                    imageFound = true
                    break
                }
            }
            
            if (imageFound) {
                // We only handle one image, so stop looking for more.
                break
            }
        }
    }

    func showError(_ error: NSError) {
        let alert = UIAlertController(title: error.localizedDescription, message: error.localizedRecoverySuggestion, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    @IBAction func done() {
        // Return any edited content to the host app.
        // This template doesn't do anything, so we just echo the passed in items.
        self.extensionContext!.completeRequest(returningItems: self.extensionContext!.inputItems, completionHandler: nil)
    }

}
