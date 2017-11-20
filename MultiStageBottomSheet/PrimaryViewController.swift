//
//  PrimaryViewController.swift
//  MultiStageBottomSheet
//
//  Created by Muzahidul Islam on 20/11/17.
//  Copyright © 2017 Muzahidul Islam. All rights reserved.
//

import UIKit

class PrimaryViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        addBottomSheet()
    }
    
    func addBottomSheet() {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let bottomSheetVC = storyBoard.instantiateViewController(withIdentifier: "BottomSheetViewController") as! BottomSheetViewController
        self.addChildViewController(bottomSheetVC)
        self.view.addSubview(bottomSheetVC.view)
        bottomSheetVC.didMove(toParentViewController: self)
        
        let height = view.frame.height
        let width  = view.frame.width
        bottomSheetVC.view.frame = CGRect(x: 0, y: self.view.frame.maxY, width: width, height: height-20)
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
