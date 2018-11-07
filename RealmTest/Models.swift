//
//  File.swift
//  RealmTest
//
//  Created by beakhand on 2018/11/05.
//  Copyright © 2018年 beakhand. All rights reserved.
//

import Foundation
import RealmSwift

class Animal: Object {
    @objc dynamic var name = ""
    @objc dynamic var age = 0
}

class Dog: Animal {
    // Person への逆方向の関連
    let persons = LinkingObjects(fromType: Person.self, property: "dog")
}

class  Cat: Animal {
    let persons = LinkingObjects(fromType: Person.self, property: "cats")
}


class UniqueObject: Object {
    @objc dynamic var id = 0
    @objc dynamic var value = ""
    // プライマリーキー指定
    override class func primaryKey() -> String? {
        return "id"
    }
}

class Person: Object {
    @objc dynamic var name = ""
    @objc dynamic var age = 0
    @objc dynamic var countryCode = ""
    @objc dynamic var dog: Dog?
    let cats = List<Cat>()
}




