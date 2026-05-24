import SwiftUI

struct MainGalleryView: View {
    @StateObject private var viewModel = GalleryViewModel()
    @Namespace private var animationNamespace
    @State private var activeAsset: PhotoAsset?
    @State private var isEditing = false
    
    var body: some View {
        ZStack {
            ZStack {
                if viewModel.isDarkMode {
                    Color.black.ignoresSafeArea()
                    Circle().fill(LinearGradient(colors: [.indigo, .purple], startPoint: .top, endPoint: .bottom)).blur(radius: 100).offset(x: -120, y: -200)
                    Circle().fill(LinearGradient(colors: [.blue, .pink], startPoint: .top, endPoint: .bottom)).blur(radius: 130).offset(x: 120, y: 300)
                } else {
                    Color.white.ignoresSafeArea()
                    Circle().fill(LinearGradient(colors: [.teal, .cyan], startPoint: .top, endPoint: .bottom)).blur(radius: 100).offset(x: -120, y: -200)
                    Circle().fill(LinearGradient(colors: [.orange, .yellow], startPoint: .top, endPoint: .bottom)).blur(radius: 130).offset(x: 120, y: 300)
                }
            }
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                HStack {
                    Text("gallery.")
                        .font(.system(size: 26, weight: .light, design: .serif))
                        .foregroundStyle(viewModel.isDarkMode ? .white : .black)
                        .onLongPressGesture(minimumDuration: 1.0) {
                            UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                                viewModel.isDarkMode.toggle()
                            }
                        }
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 22)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(LinearGradient(colors: [.white.opacity(0.4), .clear, .white.opacity(0.1)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1.5)
                        .blendMode(.overlay)
                )
                .shadow(color: .black.opacity(viewModel.isDarkMode ? 0.3 : 0.08), radius: 30, x: 0, y: 20)
                .padding(.horizontal, 16)
                .padding(.top, 12)
                
                if viewModel.authorizationStatus == .notDetermined {
                    Spacer()
                    Button(action: { viewModel.requestPermission() }) {
                        Text("grant access")
                            .font(.system(size: 13, weight: .regular, design: .monospaced))
                            .foregroundStyle(viewModel.isDarkMode ? .white : .black)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(.ultraThinMaterial)
                            .clipShape(Capsule())
                            .overlay(
                                Capsule()
                                    .stroke(LinearGradient(colors: [.white.opacity(0.5), .clear], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1)
                                    .blendMode(.overlay)
                            )
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
                        LazyVGrid(columns: [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)], spacing: 14) {
                            ForEach(viewModel.assets) { asset in
                                GridCell(asset: asset, viewModel: viewModel, animationNamespace: animationNamespace, activeAsset: $activeAsset)
                            }
                        }
                        .padding(18)
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
                        .frame(height: 190)
                        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
                        .matchedGeometryEffect(id: asset.id, in: animationNamespace)
                        .overlay(
                            RoundedRectangle(cornerRadius: 26, style: .continuous)
                                .stroke(LinearGradient(colors: [.white.opacity(0.35), .clear, .black.opacity(0.1)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1.5)
                                .blendMode(.overlay)
                        )
                        .shadow(color: .black.opacity(viewModel.isDarkMode ? 0.2 : 0.05), radius: 15, x: 0, y: 10)
                        .onTapGesture {
                            withAnimation(.spring(response: 0.32, dampingFraction: 0.8)) {
                                activeAsset = asset
                            }
                        }
                } else {
                    Color.clear
                        .frame(height: 190)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 26, style: .continuous)
                                .stroke(Color.white.opacity(0.15), lineWidth: 1)
                                .blendMode(.overlay)
                        )
                }
            } else {
                Color.clear
                    .frame(height: 190)
            }
        }
        .onAppear {
            viewModel.fetchUIImage(for: asset.asset, targetSize: CGSize(width: 350, height: 350)) { img in
                self.thumbnail = img
            }
        }
    }
}
