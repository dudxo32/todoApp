//
//  ViewController.swift
//  todoApp
//
//  Created by mac on 2022/08/12.
//

import UIKit
import SnapKit
import Then

class LaunchViewController: UIViewController {

    let todoApp = UILabel().then {
        $0.text = "TodoApp"
        $0.font = UIFont.boldSystemFont(ofSize: 30)
        $0.textColor = UIColor.black
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white

        self.view.addSubview(todoApp)
        todoApp.snp.makeConstraints { make in
            make.center.equalTo(view.snp.center)
        }
        
        UIView.animate(withDuration: 2) {
            self.view.alpha = 0
        } completion: { bool in
            self.dismiss(animated: false)
            let moveVC = MainViewController()
            let scenceDelegate = UIApplication.shared.connectedScenes.first?.delegate as! SceneDelegate
            let naviController = UINavigationController(rootViewController: moveVC)
            naviController.navigationBar.topItem?.title = "$$"
//            naviController.title = "#"
                    naviController.navigationItem.title = "$"
            
            scenceDelegate.window?.rootViewController = naviController
//            self.navigationController?.navigationBar.topItem?.title = "##"

//            scenceDelegate.window?.rootViewController?.tabBarItem.title = "EEE"
        }

        
        // Do any additional setup after loading the view.
    }


}

