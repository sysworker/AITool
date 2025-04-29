//
//  File.swift
//  toolBox
//
//  Created by wang on 2025/3/24.
//  Copyright © 2025 ToolBox. All rights reserved.
//


import UIKit

class BaseViewController: UIViewController {
    
    // MARK: - Properties
    var navView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.isHidden = false
        return view
    }()
    
    var navBarView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    var navTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 18)
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()
    
    var navLeftBtn: UIButton = {
        let button = UIButton(type: .custom)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.setTitleColor(.hex(hexString: "#989898"), for: .normal)
        button.setImage(UIImage(named: "icon_navi_back"), for: .normal)
        button.contentHorizontalAlignment = .left
        return button
    }()
    
    var navRightBtn: UIButton = {
        let button = UIButton(type: .custom)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.setTitleColor(.hex(hexString: "#989898"), for: .normal)
        button.contentHorizontalAlignment = .right
        return button
    }()
    
    var hiddenStatusBar: Bool = false {
        didSet {
            if hiddenStatusBar {
                navView.snp.updateConstraints { make in
                    make.height.equalTo(44)
                }
            } else {
                navView.snp.updateConstraints { make in
                    make.height.equalTo(statusBarHeight + 44)
                }
            }
        }
    }
    
    // MARK: - Empty View Properties
    var displayEmpty: Bool = true
    var emptyStr: String = NSLocalizedString("Empty", comment: "")
    var emptyImage: UIImage? = UIImage(named: "friend_empty")
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hiddenStatusBar = false
        displayEmpty = true
        emptyStr = NSLocalizedString("Empty", comment: "")
        emptyImage = UIImage(named: "friend_empty")
        navigationController?.navigationBar.isHidden = true

        initUI()
        view.bringSubviewToFront(navView)
    }
    
    // MARK: - UI Setup
    func initUI() {
        view.addSubview(navView)
        navView.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(view)
            make.height.equalTo(statusBarHeight + 44)
        }
        
        navView.addSubview(navBarView)
        navBarView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalTo(navView)
            make.height.equalTo(44)
        }
        
        navLeftBtn.rx.controlEvent(.touchUpInside).bind { [weak self]() in
            self?.back()
        }.disposed(by:disBag)
        navBarView.addSubview(navLeftBtn)
        navLeftBtn.snp.makeConstraints { make in
            make.leading.equalTo(navBarView).offset(15)
            make.centerY.equalTo(navBarView)
            make.height.equalTo(44)
            make.width.greaterThanOrEqualTo(44)
        }
        
        navBarView.addSubview(navRightBtn)
        navRightBtn.snp.makeConstraints { make in
            make.trailing.equalTo(navBarView).offset(-15)
            make.centerY.equalTo(navBarView)
            make.height.equalTo(44)
            make.width.greaterThanOrEqualTo(44)
        }
        
        navBarView.addSubview(navTitleLabel)
        navTitleLabel.snp.makeConstraints { make in
            make.centerX.equalTo(navBarView)
            make.centerY.equalTo(navBarView)
            make.leading.greaterThanOrEqualTo(80)
        }
    }
    
    // MARK: - Actions
    func back() {
        if let navigationController = navigationController {
            navigationController.popViewController(animated: true)
        }
    }
    
    // MARK: - Deinit
    deinit {
        #if DEBUG
        print("deinit \(self)")
        #endif
    }
}


