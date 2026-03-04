import Photos

class GalleryDeleteHandler {
    
    func deleteFromPhotoLibrary(identifierOrPath: String, completion: @escaping (Bool) -> Void) {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        
        if status == .authorized || status == .limited {
            performDelete(identifierOrPath: identifierOrPath, completion: completion)
        } else {
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { newStatus in
                if newStatus == .authorized || newStatus == .limited {
                    self.performDelete(identifierOrPath: identifierOrPath, completion: completion)
                } else {
                    completion(false)
                }
            }
        }
    }
    
    private func performDelete(identifierOrPath: String, completion: @escaping (Bool) -> Void) {
        
        let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: [identifierOrPath], options: nil)
        
        if let asset = fetchResult.firstObject {
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.deleteAssets([asset] as NSArray)
            }) { success, error in
                DispatchQueue.main.async {
                    completion(success)
                }
            }
        } else {
            findAndDeleteByFilePath(identifierOrPath, completion: completion)
        }
    }
    
    private func findAndDeleteByFilePath(_ filePath: String, completion: @escaping (Bool) -> Void) {
        let fileName = (filePath as NSString).lastPathComponent
        let fileSize = (try? FileManager.default.attributesOfItem(atPath: filePath)[.size] as? NSNumber)?.intValue ?? 0
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        let fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        
        var targetAsset: PHAsset?
        
        fetchResult.enumerateObjects { asset, _, stop in
            let resources = PHAssetResource.assetResources(for: asset)
            for resource in resources {
                if resource.originalFilename == fileName {
                    targetAsset = asset
                    stop.pointee = true
                    return
                }
                
                if let fileSizeValue = resource.value(forKey: "fileSize") as? Int, fileSizeValue == fileSize {
                    targetAsset = asset
                    stop.pointee = true
                    return
                }
            }
        }
        
        guard let asset = targetAsset else {
            DispatchQueue.main.async {
                completion(false)
            }
            return
        }
        
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.deleteAssets([asset] as NSArray)
        }) { success, error in
            DispatchQueue.main.async {
                completion(success)
            }
        }
    }
}
