import Flutter
import UIKit
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  private var gallerySaveChannel: FlutterMethodChannel?
  private var galleryDeleteChannel: FlutterMethodChannel?
  private let saveHandler = GallerySaveHandler()
  private let deleteHandler = GalleryDeleteHandler()
  
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("AIzaSyAC9WNWWUQweyMl3Lk5BHarbFAHnq_odtQ")
    
    guard let window = window,
          let controller = window.rootViewController as? FlutterViewController else {
      return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    gallerySaveChannel = FlutterMethodChannel(
      name: "com.fruitapp/gallery_save",
      binaryMessenger: controller.binaryMessenger
    )
    
    galleryDeleteChannel = FlutterMethodChannel(
      name: "com.fruitapp/gallery_delete",
      binaryMessenger: controller.binaryMessenger
    )
    
    gallerySaveChannel?.setMethodCallHandler { [weak self] (call, result) in
      guard let self = self else { return }
      if call.method == "saveToGallery" {
        guard let args = call.arguments as? [String: Any],
              let imagePath = args["imagePath"] as? String else {
          result(FlutterError(code: "INVALID_ARGUMENT", message: "imagePath is required", details: nil))
          return
        }
        
        self.saveHandler.saveToPhotoLibrary(imagePath: imagePath) { localIdentifier in
          result(localIdentifier)
        }
      } else {
        result(FlutterMethodNotImplemented)
      }
    }
    
    galleryDeleteChannel?.setMethodCallHandler { [weak self] (call, result) in
      guard let self = self else { return }
      if call.method == "deleteFromMediaStore" {
        guard let args = call.arguments as? [String: Any],
              let identifierOrPath = args["filePath"] as? String else {
          result(FlutterError(code: "INVALID_ARGUMENT", message: "filePath is required", details: nil))
          return
        }
        
        self.deleteHandler.deleteFromPhotoLibrary(identifierOrPath: identifierOrPath) { success in
          result(success)
        }
      } else {
        result(FlutterMethodNotImplemented)
      }
    }
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
