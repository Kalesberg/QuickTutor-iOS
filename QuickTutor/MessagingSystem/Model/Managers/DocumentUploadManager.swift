//
//  DocumentUploadManager.swift
//  QuickTutor
//
//  Created by Zach Fuller on 5/1/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import Foundation
import Firebase
import QuickLook

class DocumentUploadManager: NSObject, QLPreviewControllerDataSource {
    
    private let preview = QLPreviewController()
    lazy private var previewItem = NSURL()
    private let receiverId: String
    
    func showDocumentBrowser(onViewController viewController: UIViewController) {
        let documentVC = UIDocumentPickerViewController(documentTypes: ["com.apple.iwork.pages.pages", "com.apple.iwork.numbers.numbers", "com.apple.iwork.keynote.key","public.image", "com.apple.application", "public.item","public.data", "public.content", "public.audiovisual-content", "public.movie", "public.audiovisual-content", "public.video", "public.audio", "public.text", "public.data", "public.zip-archive", "com.pkware.zip-archive", "public.composite-content", "public.text"], in: .open)
        documentVC.delegate = self
        viewController.present(documentVC, animated: true, completion: nil)
    }
    
    func displayFileAtUrl(_ url: URL, fromViewController viewController: UIViewController) {
        self.downloadfileAtUrl(url, completion: {(success, fileLocationURL) in
            
            if success {
                // Set the preview item to display======
                self.previewItem = fileLocationURL! as NSURL
                // Display file
                DispatchQueue.main.async {
                    let previewController = QLPreviewController()
                    previewController.navigationController?.view.backgroundColor = Colors.darkBackground
                    previewController.dataSource = self
                    viewController.present(previewController, animated: true, completion: nil)
                }
            }else{
                debugPrint("File can't be downloaded")
            }
        })
    }
    
    private func getPreviewItem(withName name: String) -> NSURL{
        let file = name.components(separatedBy: ".")
        let path = Bundle.main.path(forResource: file.first!, ofType: file.last!)
        let url = NSURL(fileURLWithPath: path!)
        return url
    }
    
    private func downloadfileAtUrl(_ url: URL, completion: @escaping (_ success: Bool,_ fileLocation: URL?) -> Void){
        
        let itemUrl = url
        
        let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        let fileNameUrl = (url.absoluteString as NSString).lastPathComponent
        let fileName = fileNameUrl.components(separatedBy: "?")[0].removingPercentEncoding!
        let destinationUrl = documentsDirectoryURL.appendingPathComponent(fileName)
        
        if FileManager.default.fileExists(atPath: destinationUrl.path) {
            debugPrint("The file already exists at path")
            completion(true, destinationUrl)
            
        } else {
            
            URLSession.shared.downloadTask(with: itemUrl, completionHandler: { (location, response, error) -> Void in
                guard let tempLocation = location, error == nil else { return }
                do {
                    try FileManager.default.moveItem(at: tempLocation, to: destinationUrl)
                    print("File moved to documents folder")
                    completion(true, destinationUrl)
                } catch let error as NSError {
                    print(error.localizedDescription)
                    completion(false, nil)
                }
            }).resume()
        }
    }
    
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return self.previewItem as QLPreviewItem
    }
    
    init(receiverId: String) {
        self.receiverId = receiverId
    }
}

extension DocumentUploadManager: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        let url = urls[0]
        url.startAccessingSecurityScopedResource()
        uploadFileFromUrl(url)
        url.stopAccessingSecurityScopedResource()
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        
    }
    
    private func uploadFileFromUrl(_ url: URL) {
        let fileName = (url.path as NSString).lastPathComponent
        let extensionName = (url.path as NSString).pathExtension
        NotificationCenter.default.post(name: NotificationNames.Documents.didStartUpload, object: nil)
        
        do {
            let data = try Data(contentsOf: url, options: .alwaysMapped)
            url.stopAccessingSecurityScopedResource()
            let storageRef = Storage.storage().reference().child(fileName)
            
            storageRef.putData(data, metadata: nil) { _, _ in
                storageRef.downloadURL(completion: { downloadUrl, error in
                    guard let downloadUrl = downloadUrl else {
                        print("Firebase upload error", error.debugDescription)
                        return
                    }
                    MessageService.shared.sendDocumentMessage(documentUrl: downloadUrl.absoluteString, receiverId: self.receiverId, completion: {
                        
                    })
                })
            }
        } catch let error {
            print("Data error", error)
        }
    }
}
