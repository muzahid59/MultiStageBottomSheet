//
//  BottomSheetViewController.swift
//  MultiStageBottomSheet
//
//  Created by Muzahidul Islam on 20/11/17.
//  Copyright © 2017 Muzahidul Islam. All rights reserved.
//

import UIKit

enum FlickPos {
    
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


class BottomSheetViewController: UIViewController {
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var floatingView: UIView!
    
    var currPos = FlickPos.Bottom // default card position
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        let gesture = UIPanGestureRecognizer.init(target: self, action: #selector(BottomSheetViewController.panGesture))
        gesture.delegate = self
        view.addGestureRecognizer(gesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //  prepareBackgroundView()
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
        
        let translation = recognizer.translation(in: self.floatingView.superview)
        let velocity = recognizer.velocity(in: self.view)
        let location = recognizer.location(in: self.floatingView.superview)
        print("velocity",velocity)
        print("translation",translation)
        print("location",location)
        let (maxY, minY) = (self.view.frame.maxX, self.view.frame.minY)
        
        if (minY + translation.y >= FlickPos.topInset) && (minY + translation.y <= FlickPos.Bottom.yPos()) {
            self.view.frame = CGRect(x: 0, y: minY + translation.y, width: view.frame.width, height: view.frame.height)
            recognizer.setTranslation(CGPoint.zero, in: self.view)
        }
        print("floating view postion", floatingView.convert(floatingView.frame, to: self.view))
//        if location.y > FlickPos.Middle.yPos() {
//            floatingView.alpha = 1.0
//        } else {
//            floatingView.alpha = max(0, (FlickPos.Middle.yPos() - location.y)/location.y)
//            print("alpah", (FlickPos.Middle.yPos() - location.y)/location.y)
//        }
        
//        if recognizer.state == .began && searchBar.becomeFirstResponder() {
//            searchBar.resignFirstResponder()
//        }
        
        if recognizer.state == .ended {
            currPos = FlickPos.getPosition(min: minY, withDirection: velocity)
            animate(to: currPos, with: velocity)
        }
    }
    
    func animate(to position: FlickPos = .Bottom, with velocity: CGPoint) {
        
        let targetY: CGFloat = position.yPos()
        
        let duration = 0.25; let delay = 0.0
        
        UIView.animate(withDuration: duration, delay: delay, options: [.allowUserInteraction], animations: {
            
            self.view.frame = CGRect(x: 0, y: targetY, width: self.view.frame.width, height: self.view.frame.height)
            
        }, completion: { [weak self] _ in
            self?.tableView.isScrollEnabled = position == .Top
            //  self?.view.shake(velocity: velocity)
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

extension BottomSheetViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 30
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
        cell.textLabel?.text = "Cell \(indexPath.row)"
        cell.backgroundColor = indexPath.row % 2 == 0 ? .white : .red
        cell.selectionStyle = .none
        return cell
    }
}

extension BottomSheetViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        print("shouldRecognizeSimultaneouslyWith")
        print("tableview  content offset.y", tableView.contentOffset.y)
        
        let gesture = (gestureRecognizer as! UIPanGestureRecognizer)
        let direction = gesture.velocity(in: view).y
        
        print("direction",direction)
        
        if (currPos == .Top && tableView.contentOffset.y <= 0 && direction >= 0) {
            tableView.isScrollEnabled = false
            searchBar.resignFirstResponder()
            return true
        } else {
            tableView.isScrollEnabled = currPos == .Top
        }
        return false
    }
}

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
    }
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
//        if currPos == .Top {
//            currPos = .Middle
//            animate(to: .Middle, with: CGPoint(x: 0, y: -10))
//        }
        searchBar.setShowsCancelButton(false, animated: true)
        return true
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

extension BottomSheetViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print("scrollViewDidScroll")
       // searchBar.resignFirstResponder()
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


extension UIView {
    func shake(velocity: CGPoint) {
        self.transform = CGAffineTransform(translationX: 0, y: velocity.y < 0 ? -5 : 5)
        UIView.animate(withDuration: 0.1, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
            self.transform = CGAffineTransform.identity
        }, completion: nil)
    }
}

