//
//  PlayerPopUpViewController.swift
//  TanzAbend
//
//  Created by Ivashin Dmitry on 9/28/16.
//  Copyright © 2016 Ivashin Dmitry. All rights reserved.
//

import UIKit
import AVFoundation

class PlayerPopUpViewController: UIViewController {
    
    @IBOutlet var superView: UIView!
    @IBOutlet weak var popupView: UIView!
    
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var trackLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    
    @IBOutlet weak var playBtn: UIBarButtonItem!
    @IBOutlet weak var rewind: UIBarButtonItem!
    @IBOutlet weak var fastforvard: UIBarButtonItem!
    
    var player: AVAudioPlayer!
    var searchResult: SearchResult!
    
    var downloadTask: URLSessionDownloadTask?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        modalPresentationStyle = .custom
        transitioningDelegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        popupView.layer.cornerRadius = 10
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(PlayerPopUpViewController.close))
        gestureRecognizer.cancelsTouchesInView = false
        gestureRecognizer.delegate = self
        view.addGestureRecognizer(gestureRecognizer)
        superView.backgroundColor = UIColor.gray.withAlphaComponent(0.5)
        coverImageView.layer.masksToBounds = true
        coverImageView.layer.cornerRadius = 8
        configureTrackInfoOutlets()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let url = URL(string: searchResult.trackDownloadLink)
        play(url: url!)
    }
    
    func configureTrackInfoOutlets() {
        if let searchResult = searchResult {
            trackLabel.text = searchResult.track
            artistLabel.text = searchResult.artist
        }
        if let url = URL(string: searchResult.albumImageLink) {
            downloadTask = coverImageView.loadImageWithURL(url: url)
        }
    }

    @IBAction func close() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func playSTOP(_ sender: AnyObject) {
        if !player.isPlaying {
            let url = URL(string: searchResult.trackDownloadLink)
            play(url: url!)
            playBtn = UIBarButtonItem(barButtonSystemItem: .pause, target: self, action: nil)
        }
    }
    
    func play(url:URL) {
        do {
            let soundData = try! Data(contentsOf: url)
            self.player = try AVAudioPlayer(data: soundData)
            player.prepareToPlay()
            player.volume = 1.0
            player.play()
            print("!!!!!playing\(url)")
        } catch {
            print("Error getting the audio file")
        }
    }
}

extension PlayerPopUpViewController: UIViewControllerTransitioningDelegate {
    
    func presentationControllerForPresentedViewController( presented: UIViewController, presentingViewController presenting: UIViewController, sourceViewController source: UIViewController) -> UIPresentationController? {
            return UIPresentationController(presentedViewController: presented, presenting: presenting)
    }
}

extension PlayerPopUpViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return (touch.view === self.view)
    }
}
