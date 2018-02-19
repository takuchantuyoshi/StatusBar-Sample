//
//  FadeViewController.swift
//  StatusBar-sample
//
//  Created by 大澤卓也 on 2018/02/09.
//  Copyright © 2018年 Takuya Ohsawa. All rights reserved.
//

import Foundation
import UIKit

final class FadeViewController: UIViewController {
    private var isHiddenStatusBar: Bool = false {
        didSet {
            guard isHiddenStatusBar != oldValue else {
                return
            }
            guard let navigationController = navigationController else {
                return
            }
            
            if isHiddenStatusBar {
                UIView.transition(with: navigationController.navigationBar, duration: TimeInterval(UINavigationControllerHideShowBarDuration), options: [.transitionCrossDissolve], animations: {
                    navigationController.navigationBar.isHidden = true
                }, completion: { (_) in
                    navigationController.navigationBar.isHidden = false
                    navigationController.isNavigationBarHidden = true
                })
            } else {
                navigationController.isNavigationBarHidden = false
                navigationController.navigationBar.isHidden = true
                UIView.transition(with: navigationController.navigationBar, duration: TimeInterval(UINavigationControllerHideShowBarDuration), options: [.transitionCrossDissolve], animations: {
                    navigationController.navigationBar.isHidden = false
                }, completion: nil)
            }
            
            UIView.animate(withDuration: TimeInterval(UINavigationControllerHideShowBarDuration)) { [weak self] in
                self?.setNeedsStatusBarAppearanceUpdate()
            }
        }
    }
    private var lastContentOffset: CGPoint = .zero
    private var scrollDirection: ScrollDirection = .none {
        didSet {
            switch scrollDirection {
            case .up:
                isHiddenStatusBar = false
            case .down:
                isHiddenStatusBar = true
            default:
                break
            }
        }
    }
    private static let cellReuseIdentifier = "cell"
    @IBOutlet private weak var tableView: UITableView! {
        didSet {
            tableView.register(UITableViewCell.self, forCellReuseIdentifier: type(of: self).cellReuseIdentifier)
            tableView.dataSource = self
            tableView.delegate = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Fade"
    }
    
    override var prefersStatusBarHidden: Bool {
        get {
            return isHiddenStatusBar
        }
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        get {
            return .fade
        }
    }
}

extension FadeViewController: UITableViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.lastContentOffset = scrollView.contentOffset
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard !scrollView.isBouncing else {
            return
        }
        
        if self.lastContentOffset.y > scrollView.contentOffset.y {
            scrollDirection = .up
        } else if self.lastContentOffset.y < scrollView.contentOffset.y {
            scrollDirection = .down
        }
        
    }
}

extension FadeViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: type(of: self).cellReuseIdentifier, for: indexPath)
        cell.textLabel?.text = indexPath.row.description
        return cell
    }
}

