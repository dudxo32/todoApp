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

private let isSwift = true

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
                let coordinator = SUI.TodoListCoordinator(
                    initalScene: .list,
                    diContainer: SUI.TodoListDIContainer()
                )
                let root = SUI.CoordinatorScene(coordinator: coordinator)
                scenceDelegate.window?.rootViewController = UIHostingController(
                    rootView: root
                )
            
            } else {
                let naviController = UINavigationController()
                naviController.view.backgroundColor = .white
                
                scenceDelegate.window?.rootViewController = naviController
                
                let coordinator = TodoListCoordinator(
                    naviController,
                    diContainer: UIK.TodoListDIContainer()
                )

                coordinator.start()
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
    // 👉 참고로 그림자를 제거하면 네비게이션 바 아래의 선을 제거할 수 있다.
    appearance.configureWithTransparentBackground()

    appearance.backgroundColor = .white

    appearance.titleTextAttributes = [
        .font: UIFont.boldSystemFont(ofSize: 18.0),
        .foregroundColor: UIColor.black,
    ]
    //        appearance.largeTitleTextAttributes = nil
    //        [.font: UIFont.boldSystemFont(ofSize: 35.0),
    //                                               .foregroundColor: UIColor.orange]

    //        appearance.setBackgroundImage(UIImage(), for: .default)
    appearance.shadowImage = UIImage()

    UINavigationBar.appearance().standardAppearance = appearance
    UINavigationBar.appearance().compactAppearance = appearance
    UINavigationBar.appearance().scrollEdgeAppearance = appearance
//    UINavigationBar. navigationBar.isTranslucent = false
    //        navigationBar.tintColor = .red
    //        navigationBar.prefersLargeTitles = true
}
