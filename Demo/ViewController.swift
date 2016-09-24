//
//  ViewController.swift
//  Demo
//
//  Created by Suguru Kishimoto on 9/24/16.
//
//

import UIKit
import SNSShare
class ViewController: UIViewController {
    @IBOutlet private weak var button: UIButton! {
        didSet {
            button.layer.borderColor = UIColor.blue.cgColor
            button.layer.borderWidth = 1.0
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func buttonDidTap(_: UIButton) {
        
        func share(type: SNS) {
            let data = SNSShareData {
                $0.text = "sample share"
            }
            
            data.post(to: type, viewController: self) { result in
                print(result)
            }
        }
        
        let actionsheet = UIAlertController(title: "", message: "share to ...", preferredStyle: .actionSheet)
        if SNSShare.available(.twitter) {
            actionsheet.addAction(UIAlertAction(title: "Twitter", style: .default, handler: { _ in
                share(type: .twitter)
            }))
        }
        if SNSShare.available(.facebook) {
            actionsheet.addAction(UIAlertAction(title: "Facebook", style: .default, handler: { _ in
                share(type: .facebook)
            }))
        }
        if SNSShare.available(.line) {
            actionsheet.addAction(UIAlertAction(title: "Line", style: .default, handler: { _ in
                share(type: .line)
            }))
        }
        actionsheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
            
        }))
        self.present(actionsheet, animated: true, completion: nil)
    }

}

