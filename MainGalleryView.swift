import SwiftUI

struct MainGalleryView: View {
    @StateObject private var viewModel = GalleryViewModel()
    @Namespace private var animationNamespace
    @State private var activeAsset: PhotoAsset?
    @State private var isEditing = false
    
    var body: some View {
        ZStack {
            viewModel.isDarkMode ? Color.black.ignoresSafeArea() : Color.white.ignoresSafeArea()
            
            VStack(spacing: 0) {
                HStack {
                    Text("gallery.")
                        .font(.system(size: 24, weight: .light, design: .serif))
                        .foregroundStyle(viewModel.isDarkMode ? .white : .black)
                        .onLongPressGesture(minimumDuration: 1.0) {
                            UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
                            withAnimation(.easeInOut(duration: 0.35)) {
                                viewModel.isDarkMode.toggle()
                            }
                        }
                    
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 20)
                
                if viewModel.authorizationStatus == .notDetermined {
                    Spacer()
                    Button(action: { viewModel.requestPermission() }) {
                        Text("grant access")
                            .font(.system(size: 14, weight: .regular, design: .monospaced))
                            .foregroundStyle(viewModel.isDarkMode ? .white : .black)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .border(viewModel.isDarkMode ? Color.white : Color.black, width: 1)
                    }
                    Spacer()
                } else if viewModel.assets.isEmpty {
                    Spacer()
                    Text("void")
                        .font(.system(size: 13, weight: .light, design: .serif))
                        .foregroundStyle(.gray.opacity(0.4))
                    Spacer()
                } else {
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.flexible(), spacing: 1), GridItem(.flexible(), spacing: 1), GridItem(.flexible(), spacing: 1)], spacing: 1) {
                            ForEach(viewModel.assets) { asset in
                                GridCell(asset: asset, viewModel: viewModel, animationNamespace: animationNamespace, activeAsset: $activeAsset)
                            }
                        }
                    }
                }
            }
            
            if let asset = activeAsset {
                DetailOverlayView(photoAsset: asset, viewModel: viewModel, animationNamespace: animationNamespace, activeAsset: $activeAsset, isEditing: $isEditing)
            }
        }
        .environment(\.colorScheme, viewModel.isDarkMode ? .dark : .light)
    }
}

struct GridCell: View {
    let asset: PhotoAsset
    @ObservedObject viewModel: GalleryViewModel
    var animationNamespace: Namespace.ID
    @Binding var activeAsset: PhotoAsset?
    @State private var thumbnail: UIImage?
    
    var body: some View {
        ZStack {
            if activeAsset?.id != asset.id {
                if let image = thumbnail {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .frame(height: 130)
                        .clipped()
                        .matchedGeometryEffect(id: asset.id, in: animationNamespace)
                        .onTapGesture {
                            withAnimation(.snappy(duration: 0.28, extraBounce: 0.0)) {
                                activeAsset = asset
                            }
                        }
                } else {
                    Color.clear
                        .frame(height: 130)
                }
            } else {
                Color.clear
                    .frame(height: 130)
            }
        }
        .onAppear {
            viewModel.fetchUIImage(for: asset.asset, targetSize: CGSize(width: 250, height: 250)) { img in
                self.thumbnail = img
            }
        }
    }
}