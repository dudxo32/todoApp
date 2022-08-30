//
//  ViewController.swift
//  todoApp
//
//  Created by mac on 2022/08/12.
//

import UIKit
import SnapKit
import Then

class ViewController: UIViewController {

    let todoApp = UILabel().then {
        $0.text = "TodoApp"
        
        $0.font = UIFont.boldSystemFont(ofSize: 30)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(todoApp)
        todoApp.snp.makeConstraints { make in
            make.center.equalTo(view.snp.center)
        }
        
        UIView.animate(withDuration: 2) {
            self.todoApp.alpha = 0
        } completion: { bool in
            
        }

        
        // Do any additional setup after loading the view.
    }


}

