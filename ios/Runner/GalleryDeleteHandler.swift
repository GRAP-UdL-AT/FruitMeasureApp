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


    private func performDelete(identifierOrPath: String,completion: @escaping (Bool) -> Void) {

        let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: [identifierOrPath], options: nil)

        guard let asset = fetchResult.firstObject else {
            // No exact PhotoKit match: never guess another photo.
            DispatchQueue.main.async {
                completion(false)
            }
            return
        }

        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.deleteAssets([asset] as NSArray)
        }) { success, _ in
            DispatchQueue.main.async {
                completion(success)
            }
        }
    }
}


// MARK: - Batch photo deletion
extension GalleryDeleteHandler {
    /// Resolve all images first, then delete them with a single PhotoKit change
    /// request. iOS will show at most one system confirmation for the batch.
    func deleteManyFromPhotoLibrary(
        photos: [[String: String]],
        completion: @escaping (Bool) -> Void
    ) {
        guard !photos.isEmpty else {
            DispatchQueue.main.async { completion(true) }
            return
        }

        let start: () -> Void = { [weak self] in
            self?.performBatchDelete(photos: photos, completion: completion)
        }
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        if status == .authorized || status == .limited {
            start()
        } else if status == .notDetermined {
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { newStatus in
                if newStatus == .authorized || newStatus == .limited {
                    start()
                } else {
                    DispatchQueue.main.async { completion(false) }
                }
            }
        } else {
            DispatchQueue.main.async { completion(false) }
        }
    }

    private func performBatchDelete(
        photos: [[String: String]],
        completion: @escaping (Bool) -> Void
    ) {
        let identifiers = Array(Set(photos.compactMap { $0["galleryPath"] }
            .filter { !$0.isEmpty }))
        let fetched = PHAsset.fetchAssets(withLocalIdentifiers: identifiers, options: nil)

        var byIdentifier: [String: PHAsset] = [:]
        fetched.enumerateObjects { asset, _, _ in
            byIdentifier[asset.localIdentifier] = asset
        }

        var assetsByIndex: [Int: PHAsset] = [:]
        var unresolvedIndices: [Int] = []

        for (index, photo) in photos.enumerated() {

            if let id = photo["galleryPath"], !id.isEmpty {

                if let asset = byIdentifier[id] {
                    // La fotografia existeix a PhotoKit.
                    assetsByIndex[index] = asset
                } else {
                    // La fotografia no està disponible per aquest identificador.
                    // NO busquem una altra fotografia pel nom.
                    print("[GalleryDelete] Asset unavailable: \(id)")
                }

            } else {
                // Fotografia antiga sense identificador de PhotoKit.
                // Conservem el fallback existent per compatibilitat.
                unresolvedIndices.append(index)
            }
        }

        // Legacy fallback: the saved PHAsset identifier may not exist. Only
        // match an unambiguous original filename (never a size-only guess).
        var indicesByFilename: [String: [Int]] = [:]
        for index in unresolvedIndices {
            guard let filePath = photos[index]["imagePath"], !filePath.isEmpty else {
                continue
            }
            let filename = (filePath as NSString).lastPathComponent
            if !filename.isEmpty {
                indicesByFilename[filename, default: []].append(index)
            }
        }

        if !indicesByFilename.isEmpty {
            var candidates: [String: [PHAsset]] = [:]
            let images = PHAsset.fetchAssets(with: .image, options: nil)
            images.enumerateObjects { asset, _, _ in
                for resource in PHAssetResource.assetResources(for: asset) {
                    let name = resource.originalFilename
                    if indicesByFilename[name] != nil {
                        candidates[name, default: []].append(asset)
                    }
                }
            }
            for (name, indices) in indicesByFilename {
                // Duplicate names are ambiguous: do not delete the wrong photo.
                let matches = candidates[name] ?? []
                if matches.count == 1, let asset = matches.first {
                    for index in indices {
                        assetsByIndex[index] = asset
                    }
                }
            }
        }

        // Deduplicate: multiple detections/photos may refer to the same asset.
        var uniqueAssets: [PHAsset] = []
        var seen = Set<String>()
        for asset in assetsByIndex.values {
            if seen.insert(asset.localIdentifier).inserted {
                uniqueAssets.append(asset)
            }
        }

        let allResolved = assetsByIndex.count == photos.count
        guard !uniqueAssets.isEmpty else {
            DispatchQueue.main.async { completion(false) }
            return
        }

        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.deleteAssets(uniqueAssets as NSArray)
        }) { success, _ in
            DispatchQueue.main.async {
                completion(success && allResolved)
            }
        }
    }
}
