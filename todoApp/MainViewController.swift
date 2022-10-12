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
import RxSwift
import RxCocoa
import RxRelay

class MainViewController: UIViewController {
    let header = UIView().then {
        $0.backgroundColor = UIColor.red
    }
    
    let table = UIView().then {
        $0.backgroundColor = UIColor.green
    }
    
    let buton = UIButton().then {
        $0.backgroundColor = .black
    }
    let disposeBag = DisposeBag()
    let viewModel = MainViewModel()
    override func viewDidLoad() {
        self.view.backgroundColor = UIColor.backgroundFill
//                    self.navigationController?.navigationBar.topItem?.title = "##"
//        self.title = "#"
//        self.navigationItem.title = "$"
        self.view.addSubview(self.header)
        self.view.addSubview(self.table)
        self.table.addSubview(self.buton)
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
        
        self.buton.snp.makeConstraints { make in
            make.left.top.equalToSuperview()
            make.width.height.equalTo(50)
        }
        
        self.buton.rx.tap.bind(to: self.viewModel.input.click)
        
        self.viewModel.output.move.emit { _ in
            self.navigationController?.pushViewController(TestController(), animated: true)
        }

//        self.buton.rx.tap.bind(to: self.viewModel.input.click)
        
//        self.buton.rx.tap.bind(to: self.viewModel.input.click).disposed(by: self.disposeBag)
        
        
    }
    
    
}
