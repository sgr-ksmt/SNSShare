//
//  ViewController.swift
//  Demo
//
//  Created by Suguru Kishimoto
//
//

import UIKit
import SNSShare

class ViewController: UIViewController {
  
  @IBOutlet private weak var twitterButton: UIButton!
  @IBOutlet private weak var facebookButton: UIButton!
  @IBOutlet private weak var lineButton: UIButton!
  @IBOutlet private weak var textfield: UITextField! {
    didSet {
      textfield.placeholder = "Share text here!"
    }
  }
  
  // ---------- Optional Setting.
  private var images = [UIImage]()
  private var urls = [
    NSURL(string: "https://www.google.co.jp")!,
    NSURL(string: "https://www.yahoo.co.jp")!
  ]
  // ----------
  
  override func viewDidLoad() {
    super.viewDidLoad()
    NSNotificationCenter.defaultCenter().addObserver(
      self,
      selector: "updateButtons",
      name: UIApplicationDidBecomeActiveNotification,
      object: nil
    )
    updateButtons()
  }
  
  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  @objc private func updateButtons() {
    let availableList = SNSShare.availableSNSList()
    
    func update(type: SNSType, button: UIButton) {
      button.enabled = availableList.contains(type)
      button.alpha = button.enabled ? 1.0 : 0.3
    }
    
    update(.Twitter, button: twitterButton)
    update(.Facebook, button: facebookButton)
    update(.LINE, button: lineButton)
    
  }
  
  @objc @IBAction private func shareButtonDidPress(sender: UIButton!) {
    self.view.endEditing(true)
    
    var shareType: SNSType
    switch sender {
    case twitterButton: shareType = .Twitter
    case facebookButton: shareType = .Facebook
    case lineButton: shareType = .LINE
    default: return
    }
    
    let shareData = SNSShareData {
        $0.text = textfield.text ?? ""
        $0.images = images
        $0.urls = urls
    }
    shareData.post(shareType) { result in
        switch result {
        case .Success(let done):
            print(done ? "Posted!!" : "Cancelled!")
        case .Failure(let et):
            print(et)
        }
    }
    
  }
  
}

extension ViewController: UITextFieldDelegate {
  
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true
  }
}
