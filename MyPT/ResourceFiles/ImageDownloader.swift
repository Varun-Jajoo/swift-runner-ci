//
//  ImageDownloader.swift
//  MyPT
//
//  Created by techsaga corp on 20/06/25.
//

import UIKit


class ImageDownloader {
    static let shared = ImageDownloader()
    
    private let cache = NSCache<NSString, UIImage>()

    private init() {}

    func downloadImage(from urlString: String, completion: @escaping (UIImage?) -> Void) {
        let cacheKey = NSString(string: urlString)
        
        // Return from cache if available
        if let cachedImage = cache.object(forKey: cacheKey) {
            completion(cachedImage)
            return
        }

        // Else, download image
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data,
                  let image = UIImage(data: data),
                  error == nil else {
                completion(nil)
                return
            }

            // Cache the image
            self.cache.setObject(image, forKey: cacheKey)

            DispatchQueue.main.async {
                completion(image)
            }
        }.resume()
    }
}

