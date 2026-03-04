import Photos
import UIKit

class GallerySaveHandler {
    
    func saveToPhotoLibrary(imagePath: String, completion: @escaping (String?) -> Void) {
        let status = PHPhotoLibrary.authorizationStatus(for: .addOnly)
        
        if status == .authorized || status == .limited {
            performSave(imagePath: imagePath, completion: completion)
        } else {
            PHPhotoLibrary.requestAuthorization(for: .addOnly) { newStatus in
                if newStatus == .authorized || newStatus == .limited {
                    self.performSave(imagePath: imagePath, completion: completion)
                } else {
                    completion(nil)
                }
            }
        }
    }
    
    private func performSave(imagePath: String, completion: @escaping (String?) -> Void) {
        guard let image = UIImage(contentsOfFile: imagePath) else {
            DispatchQueue.main.async {
                completion(nil)
            }
            return
        }
        
        var localIdentifier: String?
        
        PHPhotoLibrary.shared().performChanges({
            let request = PHAssetChangeRequest.creationRequestForAsset(from: image)
            localIdentifier = request.placeholderForCreatedAsset?.localIdentifier
        }) { success, error in
            DispatchQueue.main.async {
                if success, let identifier = localIdentifier {
                    completion(identifier)
                } else {
                    completion(nil)
                }
            }
        }
    }
}
