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
    
     var progressTimer = Timer()
    
    @IBOutlet var superView: UIView!
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var loadingPopUp: UIView!
    @IBOutlet weak var loadingSpinner: UIActivityIndicatorView!
    @IBOutlet weak var loadingLbl: UILabel!
    
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var trackLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    
    @IBOutlet weak var playBtn: UIBarButtonItem!
    @IBOutlet weak var rewind: UIBarButtonItem!
    @IBOutlet weak var fastforvard: UIBarButtonItem!

    @IBOutlet weak var timerLbl: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var searchMessageLbl: UILabel!
    @IBOutlet weak var searchMessageView: UIView!
    
    
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
        loadingPopUp.layer.cornerRadius = 10
        loadingPopUp.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        loadingPopUp.isHidden = true
        searchMessageView.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        searchMessageView.isHidden = true
        
        if !searchResult.isFromSearchSegment {
            searchMessageView.alpha = 0.0
            searchMessageLbl.alpha = 0.0
            timeLbl.alpha = 0.0
            timerLbl.alpha = 0.0
        }
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(PlayerPopUpViewController.close))
        gestureRecognizer.cancelsTouchesInView = false
        gestureRecognizer.delegate = self
        view.addGestureRecognizer(gestureRecognizer)
        
        superView.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        coverImageView.layer.masksToBounds = true
        coverImageView.layer.cornerRadius = 8
        configureTrackInfoOutlets()
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

    //MARK: - PLAYER ACTIONS_________________________________________________________________
    
    @IBAction func rewind(_ sender: AnyObject) {
        var time: TimeInterval = player.currentTime
        time -= 5.0
        
        if time < 0 {
            close()
        }else {
            player.currentTime = time
        }
    }

    @IBAction func fastForward(_ sender: AnyObject) {
        var time: TimeInterval = player.currentTime
        time += 5.0
        
        if time > player.duration {
            close()
        } else {
            player.currentTime = time
        }
    }
    
    @IBAction func close() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func pause(_ sender: AnyObject) {
        if player.isPlaying {
            player.pause()
        }
    }
    
    @IBAction func play(_ sender: AnyObject) {
        guard let player = player else {
            let url = URL(string: searchResult.trackDownloadLink)
            loadingPopUp.isHidden = false
            loadingSpinner.startAnimating()
            DispatchQueue.main.async {
                self.play(url: url!)
                self.loadingSpinner.stopAnimating()
                self.loadingSpinner.isHidden = true
                UIView.animate(withDuration: 0.3, animations: {
                    self.loadingPopUp.backgroundColor = UIColor.clear
                })
                UIView.animate(withDuration: 0.5, animations: {
                    self.loadingLbl.center.y = 300
                })
                if self.searchResult.isFromSearchSegment {
                    UIView.animate(withDuration: 0.3, animations: {
                        self.searchMessageView.isHidden = false
                    })
                }
            }
            return
        }
        if !player.isPlaying {
           player.play()
        }
    }
    
    func play(url:URL) {
        do {
            let soundData = try! Data(contentsOf: url)
            self.player = try AVAudioPlayer(data: soundData)
            self.player.delegate = self
            player.prepareToPlay()
            player.volume = 1.0
            player.play()
            
            progressTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(PlayerPopUpViewController.updateProgressView), userInfo: nil, repeats: true)
            progressView.setProgress(Float(player.currentTime/player.duration), animated: false)
            
            print("***playing\(url)+++\(progressView.description)")
        } catch {
            print("***Error getting the audio file")
        }
    }
    
    func updateProgressView(){
        if player.isPlaying {
            progressView.setProgress(Float(player.currentTime/player.duration), animated: true)
            let timerString = String(format: "%.0f", player.duration - player.currentTime)
            timerLbl.text = timerString
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
       
        if let player = player {
            progressTimer.invalidate()
            player.delegate = nil
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

extension PlayerPopUpViewController: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        close()
    }
}

