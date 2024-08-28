import Foundation
import UIKit

final class ImageLoader {

  private let session: URLSession

  init() {
    self.session = URLSession(configuration: .default)
    self.session.configuration.urlCache = URLCache.shared
    self.session.configuration.requestCachePolicy = .returnCacheDataElseLoad
  }

  func loadImage(_ url: URL) async throws -> UIImage? {
    let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad)
    let (data, response) = try await URLSession.shared.data(for: request)
    guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
      throw URLError(.badServerResponse)
    }
    return UIImage(data: data)
  }
}

let imageLoader = ImageLoader()

extension UIImageView {

  func setImage(from url: URL?) {
    Task {
      do {
        guard let url else { throw URLError(.badURL) }
        let image = try await imageLoader.loadImage(url)
        await MainActor.run { self.image = image }
      } catch {
        self.image = nil
      }
    }
  }
}
