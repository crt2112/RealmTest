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
        //sortTest()
        queryTest()
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
    
    // クエリのテスト
    private func queryTest() {
        let realm = try! Realm()
        // age が異なる複数のPersonモデルを追加
        try! realm.write {
            realm.deleteAll() // テストなので一旦全削除
            realm.add([Person(value: ["name": "A", "age": 20]),
                       Person(value: ["name": "B", "age": 20, "countryCode": "jp"]),
                       Person(value: ["name": "C", "age": 15, "countryCode": "jp"]),
                       Person(value: ["name": "Yamada Daisuke", "age": 20, "countryCode": "jp"]),
                       Person(value: ["name": "Yu Tanaka"]),
                       Person(value: ["name": "Taichi Satou"]),
                       ])
        }
        let results = realm.objects(Person.self).filter("age >= 18 && countryCode = 'jp'")
        print("results: \(results)")

        // メソッドチェーン&前方一致
        let results2 = realm.objects(Person.self).filter("age >= 20").filter("countryCode = 'jp'").filter("name BEGINSWITH 'Y'")
        print("results2: \(results2)")
        
        // リテラル構文＆引数を使用
        let code = "jp"
        let age = 18
        var results3 = realm.objects(Person.self)
        results3 = results3.filter("age >= %@ && countryCode = %@", age, code)
        print("results3-1: \(results3)")
        
        // リテラル構文&引数を使わない書式
        results3 = realm.objects(Person.self)
        results3 = results3.filter("age >= 18 && countryCode='jp'")
        print("results3-2: \(results3)")
        results3 = realm.objects(Person.self)
        results3 = results3.filter("age >= 18 && countryCode=\"jp\"")
        print("results3-3: \(results3)")
        // プロパティ名を変数で指定する(%Kは大文字であることに注意)
        let propertyName = "countryCode"
        results3 = realm.objects(Person.self)
        results3 = results3.filter("age >= %@ && %K = %@", age, propertyName, code)
        print("results3-4: \(results3)")
        // 前方一致、部分一致、後方一致、パターンマッチ
        print("前方一致 Y:  \(realm.objects(Person.self).filter("name BEGINSWITH 'Y'"))")
        print("部分一致 dai: \(realm.objects(Person.self).filter("name CONTAINS 'Dai'"))")
        print("後方一致 ka: \(realm.objects(Person.self).filter("name ENDSWITH'ka'"))")
        // nama が *d*D?i* にパターンマッチ    ?は任意の1文字 *は任意の0文字以上
        print("パターンマッチ *d*D?i*: \(realm.objects(Person.self).filter("name LIKE'*d*D?i*'"))")
        // 大文字小文字の区別
        // 区別する
        print("大文字小文字で区別 前方一致 y: \(realm.objects(Person.self).filter("name BEGINSWITH 'y'"))")
        // 区別しばい
        print("大文字小文字で区別しない 前方一致 y: \(realm.objects(Person.self).filter("name BEGINSWITH[c] 'y'"))")
    }
}

