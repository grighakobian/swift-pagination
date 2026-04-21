#if canImport(SwiftUI)
  import SwiftUI

  #if canImport(UIKit)
    import UIKit
  #elseif canImport(AppKit)
    import AppKit
  #endif

  // MARK: - Environment values

  private struct PaginationDirectionKey: EnvironmentKey {
    static let defaultValue: PaginationDirection = .vertical
  }

  private struct PaginationLeadingScreensKey: EnvironmentKey {
    static let defaultValue: CGFloat = 2.0
  }

  private struct PaginationEnabledKey: EnvironmentKey {
    static let defaultValue: Bool = true
  }

  extension EnvironmentValues {
    public var paginationDirection: PaginationDirection {
      get { self[PaginationDirectionKey.self] }
      set { self[PaginationDirectionKey.self] = newValue }
    }

    public var paginationLeadingScreens: CGFloat {
      get { self[PaginationLeadingScreensKey.self] }
      set { self[PaginationLeadingScreensKey.self] = newValue }
    }

    public var paginationEnabled: Bool {
      get { self[PaginationEnabledKey.self] }
      set { self[PaginationEnabledKey.self] = newValue }
    }
  }

  // MARK: - Public view modifiers

  extension View {
    /// Sets the scroll direction monitored by any `.pagination` modifier in this subtree.
    public func paginationDirection(_ direction: PaginationDirection) -> some View {
      environment(\.paginationDirection, direction)
    }

    /// Sets the leading-screens prefetch threshold for any `.pagination` modifier in this
    /// subtree. Defaults to `2.0`; `0` disables prefetching.
    public func paginationLeadingScreens(_ screens: CGFloat) -> some View {
      environment(\.paginationLeadingScreens, screens)
    }

    /// Enables or disables any `.pagination` modifier in this subtree.
    public func paginationEnabled(_ enabled: Bool) -> some View {
      environment(\.paginationEnabled, enabled)
    }

    /// Attaches pagination prefetching to the nearest enclosing scroll view.
    ///
    /// The `state` binding mirrors the pagination lifecycle: `.started` just before
    /// `action` runs, `.completed` after it returns, `.failed` if it throws. Configuration
    /// (direction, leading screens, enabled) is read from the environment — set it with
    /// `.paginationDirection(_:)`, `.paginationLeadingScreens(_:)`, `.paginationEnabled(_:)`
    /// applied to any ancestor.
    ///
    /// - Parameters:
    ///   - state: Binding that receives state transitions as they happen.
    ///   - action: Async throwing closure that performs the next-page fetch.
    public func pagination(
      state: Binding<PaginationState?>,
      action: @escaping @MainActor @Sendable () async throws -> Void
    ) -> some View {
      modifier(PaginationViewModifier(state: state, action: action))
    }
  }

  // MARK: - ViewModifier

  private struct PaginationViewModifier: ViewModifier {
    @Environment(\.paginationDirection) private var direction
    @Environment(\.paginationLeadingScreens) private var leadingScreens
    @Environment(\.paginationEnabled) private var isEnabled

    @Binding var state: PaginationState?
    let action: @MainActor @Sendable () async throws -> Void

    func body(content: Content) -> some View {
      content.background(
        PaginationBridge(
          state: $state,
          action: action,
          direction: direction,
          leadingScreens: leadingScreens,
          isEnabled: isEnabled
        )
        .frame(width: 0, height: 0)
      )
    }
  }

  // MARK: - Platform bridge

  #if canImport(UIKit)

    private struct PaginationBridge: UIViewRepresentable {
      @Binding var state: PaginationState?
      let action: @MainActor @Sendable () async throws -> Void
      let direction: PaginationDirection
      let leadingScreens: CGFloat
      let isEnabled: Bool

      func makeCoordinator() -> PaginationCoordinator {
        PaginationCoordinator()
      }

      func makeUIView(context: Context) -> PaginationBridgeView {
        let view = PaginationBridgeView()
        view.coordinator = context.coordinator
        return view
      }

      func updateUIView(_ uiView: PaginationBridgeView, context: Context) {
        let coordinator = context.coordinator
        coordinator.action = action
        let binding = $state
        coordinator.stateSetter = { binding.wrappedValue = $0 }
        coordinator.direction = direction
        coordinator.leadingScreens = leadingScreens
        coordinator.isEnabled = isEnabled
        uiView.resolve()
      }
    }

    final class PaginationBridgeView: UIView {
      weak var coordinator: PaginationCoordinator?
      private weak var attachedScrollView: UIScrollView?

      init() {
        super.init(frame: .zero)
        isUserInteractionEnabled = false
        backgroundColor = .clear
      }

      required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
      }

      override func didMoveToWindow() {
        super.didMoveToWindow()
        resolve()
      }

      func resolve() {
        let scrollView = findEnclosingScrollView()
        if scrollView !== attachedScrollView {
          attachedScrollView = scrollView
          coordinator?.attach(to: scrollView)
        }
        coordinator?.applyConfiguration()
      }

      private func findEnclosingScrollView() -> UIScrollView? {
        var ancestor: UIView? = superview
        while let current = ancestor {
          if let scrollView = current as? UIScrollView { return scrollView }
          if let scrollView = searchSubtree(of: current, excluding: self) { return scrollView }
          ancestor = current.superview
        }
        return nil
      }

      private func searchSubtree(of view: UIView, excluding exclude: UIView) -> UIScrollView? {
        for subview in view.subviews where subview !== exclude {
          if let scrollView = subview as? UIScrollView { return scrollView }
          if let scrollView = searchSubtree(of: subview, excluding: exclude) { return scrollView }
        }
        return nil
      }
    }

  #elseif canImport(AppKit)

    private struct PaginationBridge: NSViewRepresentable {
      @Binding var state: PaginationState?
      let action: @MainActor @Sendable () async throws -> Void
      let direction: PaginationDirection
      let leadingScreens: CGFloat
      let isEnabled: Bool

      func makeCoordinator() -> PaginationCoordinator {
        PaginationCoordinator()
      }

      func makeNSView(context: Context) -> PaginationBridgeView {
        let view = PaginationBridgeView()
        view.coordinator = context.coordinator
        return view
      }

      func updateNSView(_ nsView: PaginationBridgeView, context: Context) {
        let coordinator = context.coordinator
        coordinator.action = action
        let binding = $state
        coordinator.stateSetter = { binding.wrappedValue = $0 }
        coordinator.direction = direction
        coordinator.leadingScreens = leadingScreens
        coordinator.isEnabled = isEnabled
        nsView.resolve()
      }
    }

    final class PaginationBridgeView: NSView {
      weak var coordinator: PaginationCoordinator?
      private weak var attachedScrollView: NSScrollView?

      override var isFlipped: Bool { true }

      override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        resolve()
      }

      func resolve() {
        let scrollView = findEnclosingScrollView()
        if scrollView !== attachedScrollView {
          attachedScrollView = scrollView
          coordinator?.attach(to: scrollView)
        }
        coordinator?.applyConfiguration()
      }

      private func findEnclosingScrollView() -> NSScrollView? {
        var ancestor: NSView? = superview
        while let current = ancestor {
          if let scrollView = current as? NSScrollView { return scrollView }
          if let scrollView = searchSubtree(of: current, excluding: self) { return scrollView }
          ancestor = current.superview
        }
        return nil
      }

      private func searchSubtree(of view: NSView, excluding exclude: NSView) -> NSScrollView? {
        for subview in view.subviews where subview !== exclude {
          if let scrollView = subview as? NSScrollView { return scrollView }
          if let scrollView = searchSubtree(of: subview, excluding: exclude) { return scrollView }
        }
        return nil
      }
    }

  #endif

  // MARK: - Coordinator

  @MainActor
  final class PaginationCoordinator: NSObject, @preconcurrency PaginationDelegate {
    var action: (@MainActor @Sendable () async throws -> Void)?
    var stateSetter: ((PaginationState?) -> Void)?
    var direction: PaginationDirection = .vertical
    var leadingScreens: CGFloat = 2.0
    var isEnabled: Bool = true

    private weak var scrollView: ScrollView?

    func attach(to scrollView: ScrollView?) {
      self.scrollView = scrollView
      scrollView?.pagination.delegate = self
    }

    func applyConfiguration() {
      guard let scrollView else { return }
      scrollView.pagination.direction = direction
      scrollView.pagination.leadingScreensForPrefetching = leadingScreens
      scrollView.pagination.isEnabled = isEnabled
    }

    func pagination(_ pagination: Pagination, prefetchNextPageWith context: PaginationContext) {
      guard let action else { return }
      context.update(state: .started)
      stateSetter?(.started)
      Task { @MainActor in
        do {
          try await action()
          context.update(state: .completed)
          self.stateSetter?(.completed)
        } catch {
          context.update(state: .failed)
          self.stateSetter?(.failed)
        }
      }
    }
  }

#endif
