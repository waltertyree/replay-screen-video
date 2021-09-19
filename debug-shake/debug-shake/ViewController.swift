//
//  ViewController.swift
//  debug-shake
//
//  Created by Walter Tyree on 8/5/21.
//

import UIKit
import ReplayKit
import AVFAudio

class ViewController: UIViewController {


  var timerCount = 0 {
    didSet {
      if self.timerCount % 2 == 0 {
        self.effectSound?.seek(to: CMTime.zero)
        self.effectSound?.play()
      }
    }
  }
  var timer: Timer?
  var controlsWindow: UIWindow?
  var effectSound: AVPlayer?

  @IBOutlet var theLabel: UILabel!
  fileprivate func startTimer() {
    // Do any additional setup after loading the view.
    timer = Timer(timeInterval: 1.0, repeats: true, block: { [weak self] _ in
      guard let self = self else { return }
      self.timerCount = self.timerCount + 1
      self.theLabel.text = "Label \(self.timerCount)"
    })
    guard let timer = timer else { return }
    RunLoop.current.add(timer, forMode: .common)

  }

  override func viewDidLoad() {
    super.viewDidLoad()
    //https://fiftysounds.com/royalty-free-music/boing-sound-effects.html
    //License for sound is non attribution, free for personal and commercial use
    self.effectSound = AVPlayer(url: Bundle.main.url(forResource: "boing", withExtension: ".caf")!)


  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    startTimer()

    controlsWindow = UIWindow(frame: CGRect(x: 0, y: 10 + view.safeAreaInsets.top, width: view.frame.width, height: 50))
    let recordingIndicator = UIButton.systemButton(with: UIImage(systemName: "record.circle")!, target: self, action: #selector(recordingToggled(_:)))
    let vc = UIViewController()
    vc.view.addSubview(recordingIndicator)
    controlsWindow?.windowScene = view.window?.windowScene
    controlsWindow?.rootViewController = vc
    controlsWindow?.makeKeyAndVisible()
    recordingIndicator.center = vc.view.center
  }


  @objc func recordingToggled(_ button: UIButton) {
    if RPScreenRecorder.shared().isRecording { //currently recordign
      RPScreenRecorder.shared().stopRecording { preview, err in
        guard let preview = preview else { print("no preview window"); return }
        button.setImage(UIImage(systemName: "record.circle"), for: .normal)
        button.tintColor = .systemBlue
        self.timer?.invalidate()
        self.controlsWindow?.isHidden = true
        self.controlsWindow?.rootViewController?.view.backgroundColor = .clear

        preview.modalPresentationStyle = .overFullScreen
        preview.previewControllerDelegate = self

        self.present(preview, animated: true)
      }
    } else { //not currently recording
      RPScreenRecorder.shared().startRecording { err in
        guard err == nil else { print(err.debugDescription); return }
        button.setImage(UIImage(systemName: "stop.circle"), for: .normal)
        button.tintColor = .white
        self.controlsWindow?.rootViewController?.view.backgroundColor = .red

      }
    }
  }


}

extension ViewController: RPPreviewViewControllerDelegate {

  func previewControllerDidFinish(_ previewController: RPPreviewViewController) {
    previewController.dismiss(animated: true) { [weak self] in
      self?.controlsWindow?.isHidden = false
      self?.startTimer()
    }
  }

}

