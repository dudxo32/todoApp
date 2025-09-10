//
//  ViewController.swift
//  todoApp
//
//  Created by mac on 2022/08/12.
//

import SnapKit
import Then
import UIKit
import SwiftUI

private let isSwift = false

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
         
            let scenceDelegate =
                UIApplication.shared.connectedScenes.first?.delegate
                as! SceneDelegate

            setupBarAppearance()

            
            if isSwift {
                let root = SUI.RootView()
                scenceDelegate.window?.rootViewController = UIHostingController(
                    rootView: root
                )
            
            } else {
                let naviController = UIK.RootNavigationController()
                naviController.view.backgroundColor = .white
                scenceDelegate.window?.rootViewController = naviController
                
               
            }
        }
        // Do any additional setup after loading the view.
    }

}

private func setupBarAppearance() {
    let appearance = UINavigationBarAppearance()
    // 반투명한 그림자를 백그라운드 앞에다 생성 (반투명한 그림자를 한겹을 쌓는다)
    //        appearance.configureWithDefaultBackground()
    // 불투명한 색상의 백그라운드 생성 (불투명한 그림자를 한겹을 쌓는다)
    //        appearance.configureWithOpaqueBackground()
    // 그림자 제거하고 기존의 백그라운드 색상을 사용 (그림자를 제거하고 기존 배경색을 사용)
    appearance.configureWithTransparentBackground()

    appearance.backgroundColor = .white

    appearance.titleTextAttributes = [
        .font: UIFont.boldSystemFont(ofSize: 18.0),
        .foregroundColor: UIColor.black,
    ]

    appearance.shadowImage = UIImage()

    UINavigationBar.appearance().standardAppearance = appearance
    UINavigationBar.appearance().compactAppearance = appearance
    UINavigationBar.appearance().scrollEdgeAppearance = appearance
}
