//
//  DownloadImageExtension.swift
//  TanzAbend
//
//  Created by Ivashin Dmitry on 9/29/16.
//  Copyright © 2016 Ivashin Dmitry. All rights reserved.
//

import UIKit

extension UIImageView {
    func loadImageWithURL(url: URL) -> URLSessionDownloadTask {
        let session = URLSession.shared
        let downloadTask = session.downloadTask(with: url as URL, completionHandler: {
            [weak self] url, response, error in
            if error == nil, let url = url, let data = NSData(contentsOf: url), let image = UIImage(data: data as Data) {
                DispatchQueue.main.async {
                    if let strongSelf = self {
                        strongSelf.image = image
                    }
                }
            }
        })
        downloadTask.resume()
        return downloadTask
    }
}
