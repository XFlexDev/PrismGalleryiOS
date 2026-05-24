import SwiftUI

struct EditorView: View {
    let originalImage: UIImage
    @ObservedObject var viewModel: GalleryViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var blurAmount: Double = 0.0
    @State private var contrastAmount: Double = 1.0
    
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    
    @State private var processedImage: UIImage?
    
    var magnificationGesture: some Gesture {
        MagnificationGesture()
            .onChanged { value in
                scale = lastScale * value
            }
            .onEnded { _ in
                lastScale = scale
            }
    }
    
    var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                offset = CGSize(width: lastOffset.width + value.translation.width, height: lastOffset.height + value.translation.height)
            }
            .onEnded { _ in
                lastOffset = offset
            }
    }
    
    var imageCanvas: some View {
        Group {
            if let processed = processedImage {
                Image(uiImage: processed)
            } else {
                Image(uiImage: originalImage)
            }
        }
        .resizable()
        .aspectRatio(contentMode: .fit)
        .scaleEffect(scale)
        .offset(offset)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                ZStack {
                    imageCanvas
                        .gesture(magnificationGesture)
                        .simultaneousGesture(dragGesture)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipShape(Rectangle())
                .overlay(
                    Rectangle()
                        .stroke(viewModel.isDarkMode ? Color.white.opacity(0.12) : Color.black.opacity(0.12), lineWidth: 1)
                        .padding(24)
                        .allowsHitTesting(false)
                )
                
                VStack(spacing: 30) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("blur refraction")
                                .font(.system(size: 11, weight: .regular, design: .monospaced))
                                .foregroundStyle(.gray)
                            Spacer()
                            Text(String(format: "%.2f", blurAmount))
                                .font(.system(size: 11, weight: .regular, design: .monospaced))
                                .foregroundStyle(.gray)
                        }
                        Slider(value: Binding(
                            get: { blurAmount },
                            set: { newValue in
                                blurAmount = newValue
                                updateEffect()
                            }
                        ), in: 0...1)
                        .tint(viewModel.isDarkMode ? .white : .black)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("glass contrast")
                                .font(.system(size: 11, weight: .regular, design: .monospaced))
                                .foregroundStyle(.gray)
                            Spacer()
                            Text(String(format: "%.2f", contrastAmount))
                                .font(.system(size: 11, weight: .regular, design: .monospaced))
                                .foregroundStyle(.gray)
                        }
                        Slider(value: Binding(
                            get: { contrastAmount },
                            set: { newValue in
                                contrastAmount = newValue
                                updateEffect()
                            }
                        ), in: 0.5...1.5)
                        .tint(viewModel.isDarkMode ? .white : .black)
                    }
                }
                .padding(.horizontal, 32)
                .padding(.vertical, 38)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 32, style: .continuous)
                        .stroke(LinearGradient(colors: [.white.opacity(0.3), .clear], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1)
                        .blendMode(.overlay)
                )
                .padding(16)
            }
            .background(viewModel.isDarkMode ? Color.black.ignoresSafeArea() : Color.white.ignoresSafeArea())
            .navigationTitle("liquid glass studio")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("cancel") { dismiss() }
                        .font(.system(size: 13, weight: .regular, design: .monospaced))
                        .foregroundStyle(viewModel.isDarkMode ? .white : .black)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("apply") { dismiss() }
                        .font(.system(size: 13, weight: .regular, design: .monospaced))
                        .foregroundStyle(viewModel.isDarkMode ? .white : .black)
                }
            }
            .onAppear {
                processedImage = originalImage
            }
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.deviceDidShakeNotification)) { _ in
                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    blurAmount = 0.0
                    contrastAmount = 1.0
                    scale = 1.0
                    offset = .zero
                    lastScale = 1.0
                    lastOffset = .zero
                    updateEffect()
                }
            }
        }
    }
    
    private func updateEffect() {
        processedImage = viewModel.applyFilters(image: originalImage, blur: blurAmount, contrast: contrastAmount)
    }
}
