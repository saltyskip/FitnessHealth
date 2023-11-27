//
//  FullScreenCoverHero.swift
//  FitnessHealth
//
//  Created by Andrei Terentiev on 19.08.23.
//

import Foundation
import SwiftUI
import MapKit

extension View {
    @ViewBuilder
    func heroFullScreenCover<Content: View>(show: Binding<Bool>, @ViewBuilder content: @escaping () -> Content) -> some View {
        self.modifier(HelperHeroView(show: show, overlay: content()))
    }
}

struct HelperHeroView<Overlay: View>: ViewModifier {
    @Binding var show: Bool
    var overlay: Overlay
    
    @State private var hostView: CustomHostingView<Overlay>?
    @State private var parentController: UIViewController?
    
    
    func body(content: Content) -> some View {
        content
            .background {
                ExtractSwiftUIParentViewController(content: overlay, hostView: $hostView) { viewController in
                    parentController = viewController
                }
            }
            .onAppear {
                hostView = CustomHostingView(show: $show, rootView: overlay)
            }
            .onChange(of: show) { newValue in
                if newValue {
                    if let hostView {
                        hostView.modalPresentationStyle = .overCurrentContext
                        hostView.modalTransitionStyle = .crossDissolve
                        hostView.view.backgroundColor = .clear
                        
                        parentController?.present(hostView, animated: false)
                    }
                } else {
                    hostView?.dismiss(animated: false)
                }
            }
    }
}

struct ExtractSwiftUIParentViewController<Content: View>: UIViewRepresentable {
    var content: Content
    @Binding var hostView: CustomHostingView<Content>?
    var parentController: (UIViewController?) -> ()
    
    func makeUIView(context: Context) -> UIView {
        return UIView()
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        hostView?.rootView = content
        DispatchQueue.main.async {
            parentController(uiView.superview?.superview?.parentController)
        }
         
    }
}

class CustomHostingView<Content: View>: UIHostingController<Content> {
    @Binding var show: Bool
    
    init(show: Binding<Bool>, rootView: Content) {
        self._show = show
        super.init(rootView: rootView)
    }
    
    required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("Something")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(false)
        show = false
    }
}

extension UIView {
    var parentController: UIViewController? {
        var responder = self.next
        while responder != nil {
            if let viewController = responder as? UIViewController {
                return viewController
            }
            responder = responder?.next
        }
        return nil
    }
}


struct DetailView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var animateHeroView: Bool = false
    @State private var animateContent: Bool = false
    var animationId: Namespace.ID
    var body: some View {
        VStack {
            if animateHeroView {
                Map(interactionModes: [.pan, .pitch, .zoom]) {
                    MapPolyline(coordinates: [] )
                        .stroke(.pink, lineWidth: 3)
                }
                .mapStyle(.standard(elevation: .realistic,
                                    pointsOfInterest: .excludingAll,
                                    showsTraffic: false))
                .frame(width: .infinity, height: 300)
                
                
                    .matchedGeometryEffect(id: "test-123-uuid", in: animationId)
            }
            
            Rectangle()
                .fill(.black)
                .frame(width: 200, height: 200)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background( content: {
            Color.white
                .ignoresSafeArea()
                .opacity(animateContent ? 1: 0)
        }
        
        )
        .overlay(alignment: .topLeading) {
            Button {
                withAnimation(.interactiveSpring(response: 0.6, dampingFraction: 0.8, blendDuration: 0.8)) {
                    animateContent = false
                    animateHeroView = false
                    dismiss()
                }
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title)
                    .foregroundColor(.primary)
            }
        }
        .onAppear {
            withAnimation(.interactiveSpring(response: 0.6, dampingFraction: 0.8, blendDuration: 0.8)) {
                animateContent = true
                animateHeroView = true
            }
        }
    }
}
