import SwiftUI
import Photos

struct PhotoAsset: Identifiable, Equatable {
    let id: String
    let asset: PHAsset
}