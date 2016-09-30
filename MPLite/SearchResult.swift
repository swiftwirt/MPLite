//
//  SearchResult.swift
//  TanzAbend
//
//  Created by Ivashin Dmitry on 9/29/16.
//  Copyright © 2016 Ivashin Dmitry. All rights reserved.
//

import UIKit

class SearchResult {
    
    var album = ""
    var albumImageLink = "http://freemusicarchive.org/file/"
    var artist = ""
    var track = ""
    var trackDownloadLink = ""
    var trackStreamURL = ""
    
    static func < (lhs: SearchResult, rhs: SearchResult) -> Bool {
        return lhs.track.localizedStandardCompare(rhs.track) == .orderedAscending
    }
}
