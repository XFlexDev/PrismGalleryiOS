import SwiftUI
import Photos
import CoreImage
import CoreImage.CIFilterBuiltins

class GalleryViewModel: ObservableObject {
    @Published var assets: [PhotoAsset] = []
    @Published var authorizationStatus: PHAuthorizationStatus = .notDetermined
    @Published var isDarkMode: Bool = true
    
    private let imageManager = PHCachingImageManager()
    private let context = CIContext()
    
    init() {
        checkPermission()
    }
    
    func checkPermission() {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        DispatchQueue.main.async {
            self.authorizationStatus = status
            if status == .authorized || status == .limited {
                self.fetchPhotos()
            }
        }
    }
    
    func requestPermission() {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
            DispatchQueue.main.async {
                self.authorizationStatus = status
                if status == .authorized || status == .limited {
                    self.fetchPhotos()
                }
            }
        }
    }
    
    func fetchPhotos() {
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let fetchResult = PHAsset.fetchAssets(with: .image, options: options)
        
        var loadedAssets: [PhotoAsset] = []
        fetchResult.enumerateObjects { (asset, _, _) in
            loadedAssets.append(PhotoAsset(id: asset.localIdentifier, asset: asset))
        }
        
        DispatchQueue.main.async {
            self.assets = loadedAssets
        }
    }
    
    func fetchUIImage(for asset: PHAsset, targetSize: CGSize, completion: @escaping (UIImage?) -> Void) {
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true
        
        imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFill, options: options) { image, _ in
            completion(image)
        }
    }
    
    func applyFilters(image: UIImage, blur: Double, contrast: Double) -> UIImage {
        guard let ciImg = CIImage(image: image) else { return image }
        
        let blurFilter = CIFilter.gaussianBlur()
        blurFilter.inputImage = ciImg
        blurFilter.radius = Float(blur * 20)
        
        guard let blurredOutput = blurFilter.outputImage else { return image }
        
        let controlsFilter = CIFilter.colorControls()
        controlsFilter.inputImage = blurredOutput
        controlsFilter.contrast = Float(contrast)
        
        guard let output = controlsFilter.outputImage,
              let cgImg = context.createCGImage(output, from: output.extent) else { return image }
        
        return UIImage(cgImage: cgImg)
    }
}