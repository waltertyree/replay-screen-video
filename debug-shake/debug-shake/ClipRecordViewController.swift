//
//  ClipRecordVCViewController.swift
//  debug-shake
//
//  Created by Walter Tyree on 9/19/21.
//

import UIKit
import AVFoundation
import ReplayKit

enum DemoType {
  case clip
  case recording
}

class ClipRecordViewController: UIViewController {

  //https://fiftysounds.com/royalty-free-music/boing-sound-effects.html
  //License for sound is non attribution, free for personal and commercial use
  let effectSound = AVPlayer(url: Bundle.main.url(forResource: "boing", withExtension: ".caf")!)

  var timer: Timer?
  var controlsWindow: UIWindow?

  var activtyViewController: UIActivityViewController?


  var demo: DemoType? {
    didSet {
      switch demo {
      case .clip:
        RPScreenRecorder.shared().startClipBuffering { err in
          if let err = err {
            print("error attempting to start buffering \(err.localizedDescription)")
          } else {
            print("Clip buffering started.")
          }
        }
        startTimer()

      case .recording:
        addRecordingButton()
        startTimer()

      default:
        break
      }
    }
  }

  fileprivate func randomPoint(in box: CGRect) -> CGPoint {
    let randomX = CGFloat.random(in: 0..<box.width)
    let randomY = CGFloat.random(in: 0..<box.height)
    return CGPoint(x: randomX, y: randomY)
  }

  fileprivate func addAnimal() {
    lazy var emoji = ["🐄","🐂", "🦙", "🐖","🐓","🐈","🐁","🐇","🐐"]

    let animalSize = CGFloat.random(in: 24...72)
    let animalRotation = CGFloat.random(in: 0...CGFloat.pi * 2)
    let animalCenter = self.randomPoint(in: self.view.bounds)
    let animalIndex = Int.random(in: 0..<emoji.count)
    let animalLabel = UILabel()
    self.view.addSubview(animalLabel)
    animalLabel.center = animalCenter

    self.effectSound.seek(to: CMTime.zero)
    self.effectSound.play()

    UIView.animate(withDuration: 0.6) {
      animalLabel.font = UIFont.systemFont(ofSize: animalSize)
      animalLabel.text = emoji[animalIndex]
      animalLabel.sizeToFit()
      animalLabel.transform = CGAffineTransform(rotationAngle: animalRotation)
    }

  }

  func startTimer() {
    // Do any additional setup after loading the view.
    timer = Timer(timeInterval: 1.0, repeats: true, block: { [weak self] _ in
      self?.addAnimal()
    })
    guard let timer = timer else { return }
    RunLoop.current.add(timer, forMode: .common)

  }


  fileprivate func addRecordingButton() {
    controlsWindow = UIWindow(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 45 + view.safeAreaInsets.top))
    controlsWindow?.windowScene = view.window?.windowScene
    controlsWindow?.makeKeyAndVisible()

    let recordingIndicator = UIButton.systemButton(with: UIImage(systemName: "record.circle")!, target: self, action: #selector(recordingToggled(_:)))
    let vc = UIViewController()
    controlsWindow?.rootViewController = vc
    vc.view.addSubview(recordingIndicator)
    recordingIndicator.center = CGPoint(x: vc.view.center.x, y: vc.view.center.y + 20)


  }




  fileprivate func selectDemoType() {
    if demo == nil {
      let alert = UIAlertController(title: "Demo Type", message: "Would you like a rolling clip demo or a screen recording demo?", preferredStyle: .alert)
      let rollingClip = UIAlertAction(title: "Rolling Clip", style: .default) { _ in
        self.demo = .clip
      }
      let recording = UIAlertAction(title: "Screen Recording", style: .default) { _ in
        self.demo = .recording
      }

      alert.addAction(rollingClip)
      alert.addAction(recording)

      self.present(alert, animated: true, completion: nil)
    }
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    selectDemoType()

    if demo != nil {
    startTimer()
    }
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
  }

  @objc func recordingToggled(_ button: UIButton) {
    if RPScreenRecorder.shared().isRecording { //currently recordign
      RPScreenRecorder.shared().stopRecording { preview, err in
        guard let preview = preview else { print("no preview window"); return }
        button.setImage(UIImage(systemName: "record.circle"), for: .normal)
        button.tintColor = .systemBlue
        self.timer?.invalidate()
        self.demo = nil
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

extension ClipRecordViewController: RPPreviewViewControllerDelegate {

  func previewControllerDidFinish(_ previewController: RPPreviewViewController) {
    previewController.dismiss(animated: true) { [weak self] in
      self?.selectDemoType()
    }
  }

}

extension ClipRecordViewController {

  override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {

    guard demo == .clip else { return }

    let clipURL: URL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("\(UUID().description).mov")
    RPScreenRecorder.shared().exportClip(to: clipURL, duration: TimeInterval(15)) { err in
      if let err = err {
        print("An error? \(err.localizedDescription )")
      } else {
        print("Clip saved to url \(clipURL)")
      }

      // Create the Array which includes the files you want to share
      var filesToShare = [Any]()

      // Add the path of the file to the Array
      filesToShare.append(clipURL)

      // Make the activityViewContoller which shows the share-view
      self.activtyViewController = UIActivityViewController(activityItems: filesToShare, applicationActivities: nil)

      self.activtyViewController?.completionWithItemsHandler = {(activityType: UIActivity.ActivityType?, completed: Bool, arrayReturnedItems: [Any]?, error: Error?) in
        self.selectDemoType()
      }


      RPScreenRecorder.shared().stopClipBuffering { err in
        if let err = err {
          print("Error attempting to stop buffering \(err.localizedDescription)")
        } else {
          print("Clip buffering stopped.")
        }
      }

      // Show the share-view
      // on the main thread
      DispatchQueue.main.async {
        self.present(self.activtyViewController!, animated: true, completion: {[weak self] in
          self?.timer?.invalidate()
          self?.demo = nil
        })
      }

    }
  }
}
