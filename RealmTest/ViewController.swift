//
//  ViewController.swift
//  RealmTest
//
//  Created by beakhand on 2018/11/05.
//  Copyright © 2018年 beakhand. All rights reserved.
//

import UIKit
import RealmSwift

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }


    @IBAction func onButtonTouchUp(_ sender: Any) {
        primaryKeyTest()
    }
    
    // プライマリーキーでモデルオブジェクトを取得
    private func primaryKeyTest() {
        let id = 1
        let realm = try! Realm()
        // レコード追加
        try! realm.write {
            realm.add(UniqueObject(value: ["id": id]))
        }
        // 追加したレコードの取得
        let object = realm.object(ofType: UniqueObject.self, forPrimaryKey: id)!
        print("object: \(object)")
        
    }
    
    // ソートしてみる
    private func sortTest() {
        
    }
}

