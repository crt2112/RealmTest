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
        //queryTest()
        //queryTest2()
        //autoUpdateTest()
        //likingObjectAutoUpdateTest()
        autoUpdateLoopObjectTest()
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
    
    // ソートのテスト
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
        // 区別しない
        print("大文字小文字で区別しない 前方一致 y: \(realm.objects(Person.self).filter("name BEGINSWITH[c] 'y'"))")
    }
    
    // クエリのテスト その２
    private func queryTest2() {
        let realm = try! Realm()
        let cat1 = Cat(value: ["name": "cat1", "age": 3])
        let cat2 = Cat(value: ["name": "cat2", "age": 5])
        let cat3 = Cat(value: ["name": "cat3", "age": 10])
        let cat4 = Cat(value: ["name": "cat4", "age": 15])
        let cat5 = Cat(value: ["name": "cat5", "age": 20])

        try! realm.write {
            realm.deleteAll() // テストなので一旦全削除
            realm.add([Person(value: ["name": "A", "age": 10, "cats": [cat1]]),
                       Person(value: ["name": "B", "age": 20, "cats": [cat1, cat2]]),
                       Person(value: ["name": "C", "age": 30, "cats": [cat1, cat2, cat3]]),
                       Person(value: ["name": "D", "age": 30, "cats": [cat1, cat2, cat3, cat4]]),
                       Person(value: ["name": "E", "age": 30, "cats": [cat1, cat3, cat4, cat5]]),
                       ])
        }
        
        let results = realm.objects(Person.self)
        
        // ANY(いずれかの要素が条件と一致する)
        // person.cats 内のがいずれかの cats.age が 10 と一致する Person モデル
        var query = results.filter("ANY cats.age == 10")
        print("ANY cats.age == 10: \(query)")
        
        // NONE(すべての要素が条件と一致しない)
        // person.cats内のすべてのcats.ageが5と一致しないpersonモデル
        query = results.filter("NONE cats.age == 5")
        print("NONE cats.age == 5: \(query)")

        // IN(いずれかの条件と一致する)
        query = results.filter("age IN {10, 20}")
        print("age IN {10, 20}: \(query)")
        
        // 集計
        // @count
        query = results.filter("cats.@count == 3") // catsの要素数が3
        print("cats.@count == 3: \(query)")
        
        // @avg ageの平均値
        let avgAge = results.value(forKeyPath: "@avg.age")
        print("@avg.age: \(String(describing: avgAge))")

        // @min
        let minAge = results.value(forKeyPath: "@min.age")
        print("@min.age: \(String(describing: minAge))")
        
        // @max
        let maxAge = results.value(forKeyPath: "@max.age")
        print("@max.age: \(String(describing: maxAge))")
        
        // @sum
        let sumAge = results.value(forKeyPath: "@sum.age")
        print("@sum.age: \(String(describing: sumAge))")

    }
    
    // マネージドオブジェクトの自動更新テスト
    private func autoUpdateTest() {
        let realm = try! Realm()
        
        //var config = Realm.Configuration
        //config.deleteRealmIfMigrationNeeded = true
        //let realm = try! Realm(configuration: config)
        
        let id = 1
        let object = UniqueObject(value: ["id": id, "value": "abc"])
        
        try! realm.write {
            realm.deleteAll() // テストなので一旦全削除
            realm.add(object) // ここで object はマネージドオブジェクトになる
        }
        
        // DB から id=1 の UniqueObject を取得
        let fetchedObject = realm.object(ofType: UniqueObject.self, forPrimaryKey: id)!
        
        // object と fetchedObject は別インスタンスだが同じデータベースのオブジェクトと参照している
        print("object.value: \(object.value)")
        print("fetchedObject.value: \(fetchedObject.value)")

        // value を xyz に更新
        try! realm.write {
            realm.create(UniqueObject.self,
                         value: ["id": id, "value": "xyz"],
                         update: true)
        }
        
        // value を確認
        print("updated object.value: \(object.value)")
        print("updated fetchedObject.value: \(fetchedObject.value)")
    }
    
    // 1:1 の逆方向の関連と自動更新の確認
    private func likingObjectAutoUpdateTest() {
        let realm = try! Realm()
        let person1 = Person(value: ["name": "Taro", "age": 32])
        let person2 = Person(value: ["name": "Jiro", "age": 30])
        let dog = Dog(value: ["name": "Momo", "age": 9])
        
        try! realm.write {
            realm.add(person1) // person1 はマネージオブジェクトになる
            realm.add(person2) // person2 はマネージオブジェクトになる
            realm.add(dog) // dog はマネージオブジェクトになる
        }
        
        // この時点で dog はどことも関連がない
        print("dog.persons.count: \(dog.persons.count)") // 0
        // person と dog を関連づける
        try! realm.write {
            person1.dog = dog
            person2.dog = dog
        }
        
        // dog の逆方向関連が自動更新されている
        print("dog.persons.count: \(dog.persons.count)")
        print("dog.persons: \(dog.persons)")
        
        // dog を削除
        try! realm.write {
            realm.delete(dog)
        }
        
        // dog 削除の自動更新確認
        print("person1.dog: \(String(describing: person1.dog))")
        print("person2.dog: \(String(describing: person2.dog))")
        
    }
    
    // 自動更新の例外テスト。 for-in ループで列挙されるオブジェクトに自動更新に影響されず、ループ開始時のおぶジェクトが列挙される
    private func autoUpdateLoopObjectTest() {
        let realm = try! Realm()
        let results = realm.objects(Cat.self).filter("age == 10")
        try! realm.write {
            realm.add([Cat(value: ["name": "cat1", "age": 10]),
                       Cat(value: ["name": "cat2", "age": 10]),
                       Cat(value: ["name": "cat3", "age": 10]),
                       Cat(value: ["name": "cat4", "age": 10]),
                       Cat(value: ["name": "cat5", "age": 10]),
                       ])
        }
        
        print("results.count: \(results.count)") // 5
        
        try! realm.write {
            // for-in で results 内の要素を変更する
            for cat in results {
                print("for-in cat.name: \(cat.name)")
                // 列挙してる cat の age を変更
                cat.age += 1
                
                // cat.age がb 11 に変更されたので results は自動更新される
                // results にアクセスすると cat が取り除かれているが、for-in 開始時の Cat はすべて列挙される
                print("for-in results.count: \(results.count)") // 4,3,2,1,0
            }
        }
        
        // すべての cat.age が変更されたので results は 0
        print("results.count: \(results.count)")

    }
}

