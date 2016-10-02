//
//  TrackCell.swift
//  TanzAbend
//
//  Created by Ivashin Dmitry on 9/28/16.
//  Copyright © 2016 Ivashin Dmitry. All rights reserved.
//

import UIKit

class TrackCell: UITableViewCell {

    @IBOutlet weak var coverImageView: UIImageView!
    
    @IBOutlet weak var albumLabel: UILabel!
    @IBOutlet weak var trackLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    
    var downloadTask: URLSessionDownloadTask?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let selectedView = UIView(frame: CGRect.zero)
        selectedView.backgroundColor = UIColor.orange
        selectedBackgroundView = selectedView
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        downloadTask?.cancel()
        downloadTask = nil
        coverImageView.image = UIImage(named: "placeholder.png")
    }
    
    func configureImageForSearchResult(searchResult: SearchResult) {
        trackLabel.text = searchResult.track
            if let url = URL(string: searchResult.albumImageLink) {
                downloadTask = coverImageView.loadImageWithURL(url: url)
                coverImageView.layer.masksToBounds = true
                coverImageView.layer.cornerRadius = 5
        }
    }
}
