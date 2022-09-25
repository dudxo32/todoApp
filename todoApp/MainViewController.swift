//
//  MainViewController.swift
//  todoApp
//
//  Created by 조영태 on 2022/09/25.
//

import Foundation
import UIKit
import SnapKit
import Then

class MainViewController: UIViewController {
    let header = UIView().then {
        $0.backgroundColor = UIColor.red
    }
    
    let table = UIView().then {
        $0.backgroundColor = UIColor.green
    }
    
    override func viewDidLoad() {
        self.view.backgroundColor = UIColor.backgroundFill
        
        self.view.addSubview(self.header)
        self.view.addSubview(self.table)
        
        self.header.snp.makeConstraints { make in
            make.height.equalTo(40)
//            make.width.equalTo(50)
            make.top.equalTo(self.view.safeAreaLayoutGuide)
            make.left.right.equalTo(self.view.safeAreaLayoutGuide).inset(C_margin16)
        }
        
        self.table.snp.makeConstraints { make in
            make.top.equalTo(header.snp.bottom).offset(24)
            make.left.right.equalTo(self.view.safeAreaLayoutGuide).inset(C_margin16)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide)
        }
    }
    
    
}
