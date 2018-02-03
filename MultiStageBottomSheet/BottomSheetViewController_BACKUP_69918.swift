//
//  BottomSheetViewController.swift
//  MultiStageBottomSheet
//
//  Created by Muzahidul Islam on 20/11/17.
//  Copyright © 2017 Muzahidul Islam. All rights reserved.
//

import UIKit
import MapKit


// MARK:- Sheet Position
public enum FlickPos {
    
    case Top, Middle, Bottom
    
    static let topInset: CGFloat = 20.0
    static let bottomInset: CGFloat = 100.0
    static let dragOffset: CGFloat = 40.0
    
    func yPos() -> CGFloat {
        switch self {
        case .Top: return FlickPos.topInset
        case .Middle: return UIScreen.main.bounds.height/2
        case .Bottom: return UIScreen.main.bounds.height - FlickPos.bottomInset
        }
    }
    
}

extension FlickPos {
    static func getPosition(min y: CGFloat, withDirection velocity: CGPoint) -> FlickPos {
        
        var cardPosition: FlickPos = .Bottom
        
        let screenHeight = UIScreen.main.bounds.height
        
        if y >= 0.0 && y <= screenHeight/2 { // position between top and middle
            
            if velocity.y >= 0 { // top to bottom direction
                if y <= dragOffset {
                    cardPosition = .Top
                    
                } else {
                    cardPosition = .Middle
                    
                }
            } else {   // bottom to top direction
                if abs(y - screenHeight/2) <= dragOffset {
                    cardPosition = .Middle
                    
                } else {
                    cardPosition = .Top
                    
                }
                
            }
            
        } else  if y > screenHeight/2  && y <= screenHeight { // position between middle and bottom
            
            if velocity.y >= 0 { // top to bottom
                
                if abs(y - screenHeight/2) <= dragOffset {
                    cardPosition = .Middle
                    
                } else {
                    cardPosition = .Bottom
                    
                }
                
                
            } else { // bottom to top
                if abs(y - (screenHeight - bottomInset)) <= dragOffset {
                    cardPosition = .Bottom
                    
                } else {
                    cardPosition = .Middle
                    
                }
                
            }
            
        }
        return cardPosition
    }
}


// MARK:- BottomSheetDelegate

 protocol BottomSheetDelegate {
    func bottomSheet(sheetVC: BottomSheetViewController?, didGoesTo position: FlickPos)
    func bottomSheet(sheetVC: BottomSheetViewController?, didChangePosition distance: CGFloat)
}


// MARK:- BottomSheetViewController

class BottomSheetViewController: UIViewController {
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var floatingView: UIView!
    
    var currPos = FlickPos.Bottom // default card position
    var delegate: BottomSheetDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        let gesture = UIPanGestureRecognizer.init(target: self, action: #selector(BottomSheetViewController.panGesture))
        gesture.delegate = self
        view.addGestureRecognizer(gesture)
        
        searchBar.layer.borderColor = UIColor.clear.cgColor
        
        tableView.rowHeight = 66.0
        tableView.estimatedRowHeight = UITableViewAutomaticDimension
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animate(withDuration: 0.6, animations: { [weak self] in
            let frame = self?.view.frame
            let yComponent = FlickPos.Bottom.yPos()
            self?.view.frame = CGRect(x: 0, y: yComponent, width: frame!.width, height: frame!.height)
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    @objc func panGesture(_ recognizer: UIPanGestureRecognizer) {
        
        let translation = recognizer.translation(in: self.view)
        let velocity = recognizer.velocity(in: self.view)
        let location = recognizer.location(in: self.view)
       // print("velocity",velocity)
       // print("translation",translation)
       // print("location",location)
        let (maxY, minY) = (self.view.frame.maxX, self.view.frame.minY)
       // print("maxY", maxY, "minY",minY)
        if (minY + translation.y >= FlickPos.topInset) && (minY + translation.y <= FlickPos.Bottom.yPos()) {
            self.view.frame = CGRect(x: 0, y: minY + translation.y, width: view.frame.width, height: view.frame.height)
            recognizer.setTranslation(CGPoint.zero, in: self.view)
        }
        
        if minY > FlickPos.Middle.yPos() {
            floatingView.alpha = 1.0
        } else {
        
            floatingView.alpha = max(0, 0.3 - abs((FlickPos.Middle.yPos() - minY))/FlickPos.Middle.yPos())
           
        }

        if recognizer.state == .changed {
            delegate?.bottomSheet(sheetVC: self, didChangePosition: minY)
        }
        if recognizer.state == .ended {
            currPos = FlickPos.getPosition(min: minY, withDirection: velocity)
            animate(to: currPos, with: velocity)
        }
    }

    
    func animate(to position: FlickPos = .Bottom, with velocity: CGPoint) {
        
        let targetY: CGFloat = position.yPos()
        
        let duration = 0.25; let delay = 0.0
        
       // print(#function)
        debugPrint(#function)
        
        UIView.animate(withDuration: duration, delay: delay, options: [.allowUserInteraction], animations: {  [weak self] in
            
            self?.view.frame = CGRect(x: 0, y: targetY, width: self?.view.frame.width ?? 0, height: self?.view.frame.height ?? 0)
            self?.floatingView.alpha = (position == .Top) ? 0 : 1
            
        }, completion: { [weak self] _ in
            self?.tableView.isScrollEnabled = position == .Top
            self?.delegate?.bottomSheet(sheetVC: self, didGoesTo: position)
        })
    }
    
    func prepareBackgroundView() {
        let blurEffect = UIBlurEffect.init(style: .dark)
        let visualEffect = UIVisualEffectView.init(effect: blurEffect)
        let bluredView = UIVisualEffectView.init(effect: blurEffect)
        bluredView.contentView.addSubview(visualEffect)
        visualEffect.frame = UIScreen.main.bounds
        bluredView.frame = UIScreen.main.bounds
        view.insertSubview(bluredView, at: 0)
    }
    
}


// MARK:- UITableView DataSource and Delegate

extension BottomSheetViewController: UITableViewDelegate, UITableViewDataSource {
    
<<<<<<< HEAD
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 30
    }
=======
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 30
    }
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 70
//    }
>>>>>>> 61fced21c493ccf9537b1b0457b66213b967d055
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SheetCell") as! SheetCell
        cell.titleLabel.text = "Dhaka, mirpur road no: \(indexPath.row)"
        cell.subtitleLabel.text = "\(indexPath.row) Places"
        return cell
    }
}


// MARK:- UIGestureRecognizerDelegate
<<<<<<< HEAD

=======
>>>>>>> 61fced21c493ccf9537b1b0457b66213b967d055
extension BottomSheetViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        let gesture = (gestureRecognizer as! UIPanGestureRecognizer)
        let direction = gesture.velocity(in: view).y
        if (currPos == .Top && tableView.contentOffset.y <= 0 && direction >= 0) {
            tableView.isScrollEnabled = false
            if direction != 0 {
                searchBar.resignFirstResponder()
            }
            return true
        } else {
            tableView.isScrollEnabled = currPos == .Top
        }
        return false
    }
}

// MARK:-  UISearchBarDelegate
extension BottomSheetViewController: UISearchBarDelegate {
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        if currPos != .Top {
            currPos = .Top
            animate(to: .Top, with: CGPoint(x: 0, y: 10))
        }
        searchBar.setShowsCancelButton(true, animated: true)
        return true
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        if currPos == .Top {
            currPos = .Bottom
            animate(to: .Bottom, with: CGPoint(x: 0, y: -10))
        }
        
    }
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        
        searchBar.setShowsCancelButton(false, animated: false)
        return true
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

<<<<<<< HEAD
=======
// MARK:-  UIScrollViewDelegate
extension BottomSheetViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print("scrollViewDidScroll")
    
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        print("scrollViewDidEndDragging")
    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        print("scrollViewWillBeginDragging")
    }
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        print("scrollViewWillEndDragging")
    }
}

>>>>>>> 61fced21c493ccf9537b1b0457b66213b967d055
// MARK:- Shaking
extension UIView {
    func shake(velocity: CGPoint) {
        self.transform = CGAffineTransform(translationX: 0, y: velocity.y < 0 ? -5 : 5)
        UIView.animate(withDuration: 0.1, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
            self.transform = CGAffineTransform.identity
        }, completion: nil)
    }
}

