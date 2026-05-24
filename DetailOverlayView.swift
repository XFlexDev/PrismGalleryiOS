import SwiftUI

struct DetailOverlayView: View {
    let photoAsset: PhotoAsset
    @ObservedObject var viewModel: GalleryViewModel
    var animationNamespace: Namespace.ID
    @Binding var activeAsset: PhotoAsset?
    @Binding var isEditing: Bool
    
    @State private var displayImage: UIImage?
    @State private var dragOffset = CGSize.zero
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(.ultraThinMaterial)
                .opacity(max(0.3, 1.0 - Double(abs(dragOffset.height) / 600)))
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                        activeAsset = nil
                    }
                }
            
            VStack {
                HStack {
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                            activeAsset = nil
                        }
                    }) {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 16, weight: .light))
                            .foregroundStyle(viewModel.isDarkMode ? .white : .black)
                            .frame(width: 40, height: 40)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white.opacity(0.2), lineWidth: 1).blendMode(.overlay))
                    }
                    Spacer()
                    Button(action: { isEditing = true }) {
                        Text("adjust")
                            .font(.system(size: 12, weight: .regular, design: .monospaced))
                            .foregroundStyle(viewModel.isDarkMode ? .white : .black)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(.ultraThinMaterial)
                            .clipShape(Capsule())
                            .overlay(Capsule().stroke(Color.white.opacity(0.2), lineWidth: 1).blendMode(.overlay))
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
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .offset(dragOffset)
                        .padding(.horizontal, 16)
                        .gesture(
                            DragGesture()
                                .onChanged { gesture in
                                    dragOffset = gesture.translation
                                }
                                .onEnded { gesture in
                                    if abs(gesture.translation.height) > 100 {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                                            activeAsset = nil
                                        }
                                    } else {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
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
            viewModel.fetchUIImage(for: photoAsset.asset, targetSize: CGSize(width: 1400, height: 1400)) { img in
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
