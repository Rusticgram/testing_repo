import UIKit
import Flutter
import Photos
import MobileCoreServices
import UserNotifications
import BranchSDK

@main
@objc class AppDelegate: FlutterAppDelegate, UIDocumentInteractionControllerDelegate {
  private let CHANNEL_DOWNLOAD = "download_image"
  private let CHANNEL_REFRESH = "refresh_dir"
  private let CHANNEL_DOWNLOAD_INVOICE = "download_invoice"
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

        // Setup Notification delegate
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
        }

         Branch.getInstance().initSession(launchOptions: launchOptions) { (params, error) in
            print(params as? [String: AnyObject] ?? {})
            // Access and use Branch Deep Link data here (nav to page, display content, etc.)
        }

        let controller: FlutterViewController = window?.rootViewController as! FlutterViewController

       // Register MethodChannel for downloading PDF invoices
        let downloadInvoiceChannel = FlutterMethodChannel(name: CHANNEL_DOWNLOAD_INVOICE, binaryMessenger: controller.binaryMessenger)
        downloadInvoiceChannel.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
            guard let self = self else { return }
            if call.method == "download_invoice" {
                if let args = call.arguments as? [String: Any],
                let invoiceUrl = args["invoiceUrl"] as? String,
                let fileName = args["fileName"] as? String {  // Get file name from Flutter
                    print("Starting PDF download for URL: \(invoiceUrl) with file name: \(fileName)")  // Logging
                    self.downloadInvoicePdf(invoiceUrl: invoiceUrl, fileName: fileName) { filePath in
                        if let filePath = filePath {
                            print("PDF downloaded successfully. File path: \(filePath)")  // Logging
                            result(filePath)  // Return file path to Flutter
                        } else {
                            print("Failed to download PDF.")  // Logging
                            result(FlutterError(code: "DOWNLOAD_FAILED", message: "Failed to download the PDF", details: nil))
                        }
                    }
                } else {
                    print("Invalid arguments: Invoice URL or file name missing.")  // Logging
                    result(FlutterError(code: "INVALID_ARGUMENT", message: "Invoice URL and file name are required", details: nil))
                }
            } else {
                result(FlutterMethodNotImplemented)
            }
        }

        // Register MethodChannel for downloading images with watermark
        let downloadImageChannel = FlutterMethodChannel(name: CHANNEL_DOWNLOAD, binaryMessenger: controller.binaryMessenger)
        downloadImageChannel.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
            guard let self = self else { return }
            if call.method == "download_image" {
                if let args = call.arguments as? [String: Any],
                   let imageData = args["imageBytes"] as? FlutterStandardTypedData,
                   let watermarkPath = args["watermarkPath"] as? String {
                    if let processedBytes = self.processImageBytesWithWatermark(imageData: imageData.data, watermarkPath: watermarkPath) {
                        result(processedBytes)
                    } else {
                        result(FlutterStandardTypedData(bytes: Data()))
                    }
                } else {
                    result(FlutterError(code: "INVALID_ARGUMENT", message: "Invalid image bytes or watermark path", details: nil))
                }
            } else {
                result(FlutterMethodNotImplemented)
            }
        }

        // Register MethodChannel for refreshing the file (single file path)
        let refreshFileChannel = FlutterMethodChannel(name: CHANNEL_REFRESH, binaryMessenger: controller.binaryMessenger)
        refreshFileChannel.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
            guard let self = self else { return }
            if call.method == "refresh_dir" {
                if let args = call.arguments as? [String: Any], // Expecting a dictionary
                let filePath = args["dirPath"] as? String {  // Extracting the file path using the key "dirPath"
                    self.refreshFile(filePath: filePath)
                    result(true)
                } else {
                    result(FlutterError(code: "INVALID_ARGUMENT", message: "File path is required", details: nil))
                }
            } else {
                result(FlutterMethodNotImplemented)
            }
        }


    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

    // Process the provided image bytes by adding a watermark and return the processed bytes
    private func processImageBytesWithWatermark(imageData: Data, watermarkPath: String) -> FlutterStandardTypedData? {
        guard let image = UIImage(data: imageData),
              let watermark = UIImage(contentsOfFile: watermarkPath) else {
            print("Failed to decode image or watermark")
            return nil
        }

        let scaleFactor = (image.size.width * 0.2) / watermark.size.width
        let watermarkSize = CGSize(width: watermark.size.width * scaleFactor, height: watermark.size.height * scaleFactor)

        UIGraphicsBeginImageContextWithOptions(image.size, false, 0)
        image.draw(in: CGRect(origin: .zero, size: image.size))

        let padding: CGFloat = 20
        let watermarkPosition = CGPoint(x: image.size.width - watermarkSize.width - padding,
                                        y: image.size.height - watermarkSize.height - padding)

        watermark.draw(in: CGRect(origin: watermarkPosition, size: watermarkSize), blendMode: .normal, alpha: 0.78)

        let resultImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        guard let processedData = resultImage?.jpegData(compressionQuality: 1.0) else {
            return nil
        }

        return FlutterStandardTypedData(bytes: processedData)
    }

    // Refresh a single file (image or document)
    private func refreshFile(filePath: String) {
        let fileUrl = URL(fileURLWithPath: filePath)
        let fileExtension = fileUrl.pathExtension.lowercased()

        let mimeType: String
        switch fileExtension {
        case "jpg", "jpeg":
            mimeType = "image/jpeg"
            refreshImage(fileUrl: fileUrl)
        case "pdf":
            mimeType = "application/pdf"
            refreshDocument(fileUrl: fileUrl)
        default:
            print("Unsupported file type: \(fileExtension)")
            return
        }
    }

    // Handle image refresh in the Photos library
    private func refreshImage(fileUrl: URL) {
        DispatchQueue.main.async {
            PHPhotoLibrary.shared().performChanges({
                let creationRequest = PHAssetCreationRequest.forAsset()
                creationRequest.addResource(with: .photo, fileURL: fileUrl, options: nil)
            }) { success, error in
                if success {
                    print("Image refreshed successfully: \(fileUrl.path)")
                } else if let error = error {
                    print("Error refreshing image: \(error.localizedDescription)")
                }
            }
        }
    }

    // Handle document (PDF) refresh, simply making sure it's saved properly
    private func refreshDocument(fileUrl: URL) {
        // Check if the file exists in the temporary location
        if FileManager.default.fileExists(atPath: fileUrl.path) {
            print("PDF is available at path: \(fileUrl.path)")
            
            do {
                // Get the destination path in the Documents directory
                let documentsDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                let destinationUrl = documentsDirectory.appendingPathComponent(fileUrl.lastPathComponent)
                
                // If the file already exists in the destination, don't overwrite it
                if FileManager.default.fileExists(atPath: destinationUrl.path) {
                    print("PDF already exists in Documents folder: \(destinationUrl.path)")
                } else {
                    // Move the file from the temporary location to the Documents directory
                    try FileManager.default.moveItem(at: fileUrl, to: destinationUrl)
                    print("File successfully saved to Documents: \(destinationUrl.path)")
                }
                
            } catch {
                print("Error moving file to Documents: \(error.localizedDescription)")
            }
        } else {
            print("PDF file does not exist at path: \(fileUrl.path)")
        }
    }






    // Function to download the PDF and save it to the Documents directory
    private func downloadInvoicePdf(invoiceUrl: String, fileName: String, completion: @escaping (String?) -> Void) {
        guard let url = URL(string: invoiceUrl) else {
            print("Invalid URL: \(invoiceUrl)")
            completion(nil)
            return
        }

        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let destinationUrl = documentsDirectory.appendingPathComponent("\(fileName).pdf")
        
        print("Attempting to download the PDF from URL: \(url)")
        print("File will be saved at: \(destinationUrl.path)")

        let task = URLSession.shared.downloadTask(with: url) { location, response, error in
            if let error = error {
                print("Download error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }

            guard let location = location else {
                print("Download failed: No file location")
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }

            do {
                // Check if file already exists and remove it
                if FileManager.default.fileExists(atPath: destinationUrl.path) {
                    print("File already exists at path: \(destinationUrl.path). Deleting the existing file.")
                    try FileManager.default.removeItem(at: destinationUrl)
                }
                
                // Move the downloaded file to the Documents directory
                print("Moving downloaded file from temporary location to destination: \(destinationUrl.path)")
                try FileManager.default.moveItem(at: location, to: destinationUrl)
                
                print("File successfully downloaded and moved to: \(destinationUrl.path)")
                DispatchQueue.main.async {
                    completion(destinationUrl.path)
                }
            } catch {
                print("Error moving downloaded file: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
        
        task.resume()
    }

    // Clear all notifications
    override func applicationWillEnterForeground(_ application: UIApplication) {
        application.applicationIconBadgeNumber = 0
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }
}
