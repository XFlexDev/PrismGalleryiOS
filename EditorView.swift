import SwiftUI

struct EditorView: View {
    let originalImage: UIImage
    @ObservedObject viewModel: GalleryViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var blurAmount: Double = 0.0
    @State private var contrastAmount: Double = 1.0
    
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    
    @State private var processedImage: UIImage?
    
    var body: some View {
        NavigationView {
            ZStack {
                viewModel.isDarkMode ? Color.black.ignoresSafeArea() : Color.white.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    ZStack {
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
                        .gesture(
                            MagnificationGesture()
                                .onChanged { value in
                                    scale = lastScale * value
                                }
                                .onEnded { _ in
                                    lastScale = scale
                                }
                        )
                        .simultaneousGesture(
                            DragGesture()
                                .onChanged { value in
                                    offset = CGSize(width: lastOffset.width + value.translation.width, height: lastOffset.height + value.translation.height)
                                }
                                .onEnded { _ in
                                    lastOffset = offset
                                }
                        )
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipShape(Rectangle())
                    .overlay(
                        Rectangle()
                            .stroke(viewModel.isDarkMode ? Color.white.opacity(0.15) : Color.black.opacity(0.15), lineWidth: 1)
                            .padding(30)
                            .allowsHitTesting(false)
                    )
                    
                    VStack(spacing: 28) {
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text("blur")
                                    .font(.system(size: 11, weight: .regular, design: .monospaced))
                                    .foregroundStyle(.gray)
                                Spacer()
                                Text(String(format: "%.2f", blurAmount))
                                    .font(.system(size: 11, weight: .regular, design: .monospaced))
                                    .foregroundStyle(.gray)
                            }
                            Slider(value: $blurAmount, in: 0...1)
                                .tint(viewModel.isDarkMode ? .white : .black)
                                .onChange(of: blurAmount) { _ in updateEffect() }
                        }
                        
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text("contrast")
                                    .font(.system(size: 11, weight: .regular, design: .monospaced))
                                    .foregroundStyle(.gray)
                                Spacer()
                                Text(String(format: "%.2f", contrastAmount))
                                    .font(.system(size: 11, weight: .regular, design: .monospaced))
                                    .foregroundStyle(.gray)
                                }
                            Slider(value: $contrastAmount, in: 0.5...1.5)
                                .tint(viewModel.isDarkMode ? .white : .black)
                                .onChange(of: contrastAmount) { _ in updateEffect() }
                        }
                    }
                    .padding(.horizontal, 32)
                    .padding(.vertical, 36)
                    .background(viewModel.isDarkMode ? Color.white.opacity(0.02) : Color.black.opacity(0.02))
                }
            }
            .navigationTitle("refine")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("dismiss") { dismiss() }
                        .font(.system(size: 13, weight: .regular, design: .monospaced))
                        .foregroundStyle(viewModel.isDarkMode ? .white : .black)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("commit") { dismiss() }
                        .font(.system(size: 13, weight: .regular, design: .monospaced))
                        .foregroundStyle(viewModel.isDarkMode ? .white : .black)
                }
            }
            .onAppear {
                processedImage = originalImage
            }
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.deviceDidShakeNotification)) { _ in
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                withAnimation(.smooth(duration: 0.25)) {
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

extension UIDevice {
    static let deviceDidShakeNotification = Notification.Name("deviceDidShakeNotification")
}

extension UIWindow {
    open override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            NotificationCenter.default.post(name: UIDevice.deviceDidShakeNotification, object: nil)
        }
    }
}