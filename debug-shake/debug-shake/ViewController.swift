//
//  ViewController.swift
//  debug-shake
//
//  Created by Walter Tyree on 8/5/21.
//

import UIKit

class ViewController: UIViewController {


  var timerCount = 0
  var timer: Timer?
  @IBOutlet var theLabel: UILabel!
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    timer = Timer(timeInterval: 1.0, repeats: true, block: { [weak self] _ in
      guard let self = self else { return }
      self.timerCount = self.timerCount + 1
      self.theLabel.text = "Label \(self.timerCount)"

    })
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    guard let timer = timer else { return }
    RunLoop.current.add(timer, forMode: .common)
  }




}

