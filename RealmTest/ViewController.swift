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
        //primaryKeyTest()
        sortTest()
    }
    
    // プライマリーキーでモデルオブジェクトを取得
    private func primaryKeyTest() {
        let id = 1
        let realm = try! Realm()
        
        // レコード追加
        try! realm.write {
            realm.deleteAll() // テストなので一旦全削除
            realm.add(UniqueObject(value: ["id": id]))
        }
        // 追加したレコードの取得
        let object = realm.object(ofType: UniqueObject.self, forPrimaryKey: id)!
        print("object: \(object)")
        
    }
    
    // ソートしてみる
    private func sortTest() {
        let realm = try! Realm()
        // age が異なる複数のPersonモデルを追加
        try! realm.write {
            realm.deleteAll() // テストなので一旦全削除
            realm.add([Person(value: ["name": "B", "age": 20]),
                       Person(value: ["name": "A", "age": 10]),
                       Person(value: ["name": "C", "age": 30]),
                       ])
        }
        // すべて取得
        var results = realm.objects(Person.self)
        print("results not sort: \(results)")
        // age で昇順ソート
        results = results.sorted(byKeyPath: "age", ascending: true)
        print("results sorted: \(results)")
        // 1件レコード追加
        try! realm.write {
            realm.add([Person(value: ["name": "D", "age": 15])])
        }
        // そのままソートに反映されているか確認
        print("results sorted added: \(results)")
    }
}

