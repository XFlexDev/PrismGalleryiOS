import SwiftUI

struct DetailOverlayView: View {
    let photoAsset: PhotoAsset
    @ObservedObject viewModel: GalleryViewModel
    var animationNamespace: Namespace.ID
    @Binding var activeAsset: PhotoAsset?
    @Binding var isEditing: Bool
    
    @State private var displayImage: UIImage?
    @State private var dragOffset = CGSize.zero
    
    var body: some View {
        ZStack {
            (viewModel.isDarkMode ? Color.black : Color.white)
                .opacity(max(0.4, 1.0 - Double(abs(dragOffset.height) / 500)))
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.snappy(duration: 0.24, extraBounce: 0.0)) {
                        activeAsset = nil
                    }
                }
            
            VStack {
                HStack {
                    Button(action: {
                        withAnimation(.snappy(duration: 0.24, extraBounce: 0.0)) {
                            activeAsset = nil
                        }
                    }) {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 15, weight: .light))
                            .foregroundStyle(viewModel.isDarkMode ? .white : .black)
                    }
                    Spacer()
                    Button(action: { isEditing = true }) {
                        Text("adjust")
                            .font(.system(size: 13, weight: .regular, design: .monospaced))
                            .foregroundStyle(viewModel.isDarkMode ? .white : .black)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                
                Spacer()
                
                if let image = displayImage {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .matchedGeometryEffect(id: photoAsset.id, in: animationNamespace)
                        .offset(dragOffset)
                        .gesture(
                            DragGesture()
                                .onChanged { gesture in
                                    dragOffset = gesture.translation
                                }
                                .onEnded { gesture in
                                    if abs(gesture.translation.height) > 90 {
                                        withAnimation(.snappy(duration: 0.24, extraBounce: 0.0)) {
                                            activeAsset = nil
                                        }
                                    } else {
                                        withAnimation(.snappy(duration: 0.24, extraBounce: 0.0)) {
                                            dragOffset = .zero
                                        }
                                    }
                                }
                        )
                } else {
                    ProgressView()
                        .tint(viewModel.isDarkMode ? .white : .black)
                }
                
                Spacer()
            }
        }
        .onAppear {
            viewModel.fetchUIImage(for: photoAsset.asset, targetSize: CGSize(width: 1200, height: 1200)) { img in
                self.displayImage = img
            }
        }
        .sheet(isPresented: $isEditing) {
            if let image = displayImage {
                EditorView(originalImage: image, viewModel: viewModel)
            }
        }
    }
}