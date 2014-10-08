"use strict"
expect = require("expect.js")
LocalDB = require("../src/localdb.js")
Collection = require("../src/lib/collection.js")
Utils = require('../src/lib/utils.js')


db = new LocalDB("foo")

describe "Collection", ->
    bar = db.collection("bar")
    it "Init", ->
        expect(bar instanceof Collection).to.be(true)
    it "Insert", ->
        bar.insert {
            a: 1
            b: "abc"
            c: /hell.*ld/
            d: {e: 4, f: "5"}
            g: (h) -> return h * 3
            i: [1,2,3]
        }
        data = bar.find()[0]
        expect(data.a).to.be(1)
        expect(data.b).to.be("abc")
        expect(data.c.test("hello world")).to.be(true)
        expect(data.d).to.be.eql({e:4, f: "5"})
        expect(Utils.isFunction(data.g)).to.be(true)
        expect(data.g(100)).to.be(300)
        expect(data.i).to.be.eql([1,2,3])
    it "Insert List", ->
        bar.drop()
        bar.insert [
            {
                a:1
                b:2
                c:3
            },
            {
                a:2
                b:3
                c:4
            }
        ]
        expect(bar.find().length).to.be(2)
        bar.insert [
            {
                a:1
                b:2
                c:3
            }
            4 #只能插入对象，该数据将被过滤掉，不会被插入
            {
                a:2
                b:3
                c:4
            }
        ]
        expect(bar.find().length).to.be(4)
    it "Update", ->
        bar.drop()
        bar.insert {
            a: 1
            b: 2
            c: {d: 3, e:4}
            f: (x) -> x * x
            g: [1,2,3,4]
            h: "abc"
            price: 10.99
            max1: 100
            max2: 200
            min1: 50
            min2: 30
            unchanged_val: 100
        }
        bar.update {
            $set: {
                a:4
                "c.d": 5
            }
            $inc: {
                b: 2
            }
            $rename: {f:"function"}
            $unset: {h:""}
            $mul: {price: 1.25}
            $max: {max1:120, max2:150}
            $min: {min1:80, min2: 10}
            unchanged_val: 119 #it will be ignored
        }
        data = bar.find()[0]
        expect(data.a).to.be(4)
        expect(data.c.d).to.be(5)
        expect(data.b).to.be(4)
        expect(data.f).not.to.be.ok()
        expect(Utils.isFunction(data.function)).to.be(true)
        expect(data.function(9)).to.be(81)
        expect(data.h).not.to.be.ok()
        expect(data.max1).to.be(120)
        expect(data.max2).to.be(200)
        expect(data.min1).to.be(50)
        expect(data.min2).to.be(10)
        expect(data.unchanged_val).to.be(100)
        bar.drop()
        bar.insert {
            a: 1
        }
        bar.update {
            $set: {
                a: 2
            }
        }, {
            where: {a:2}
        }
        data = bar.find()[0]
        expect(data.a).to.be(1)
        bar.update {
            $set: {
                b: 2
                "b.c": 1
            }
        }, {
            where: {a:1}
        }
        data = bar.find()[0]
        expect(data.b).not.to.be.ok()
        bar.update {
            $set: {
                b: 2
                "d.c": 3
            }
        }, {
            where: {a: 1}
            upsert: true
        }
        data = bar.findOne()
        expect(data.b).to.be(2)
        bar.drop()
        bar.insert [
            {a:1, b:2}
            {a:1, b:3}
            {a:1, b:4}
        ]
        bar.update {
            $set: {
                b: 5
            }
        }, {
            where: {
                a: 1
            }
            multi: false
        }
        data = bar.find()
        expect(d.b).not.to.be(5) for d,index in data  when index > 0
    it "Remove", ->
        bar.drop()
        bar.insert [
            {a: 1,b: 2}
            {a: 1,b: 3}
            {a: 2,b: 4}
        ]
        bar.remove()
        data = bar.find()
        expect(bar.find()).to.be.eql([])
        bar.drop()
        bar.insert [
            {a: 1,b: 2}
            {a: 1,b: 3}
            {a: 2,b: 4}
        ]
        bar.remove {
            where: {a:1}
            multi: false
        }
        expect(bar.find({where: {a: 1}}).length).to.be(1)
        bar.drop()
        bar.insert [
            {a: 1,b: 2}
            {a: 1,b: 3}
            {a: 2,b: 4}
            {a: 3,b: 4}
        ]
        bar.remove {
            where: {a:1}
        }
        expect(bar.find({where: {a: 1}}).length).to.be(0)
        expect(bar.find().length).to.be(2)
    it "FindOne", ->
        bar.drop()
        bar.insert [{
            a: 1
            b: 2
            c: {d: 3, e:4}
            f: (x) -> x * x
            g: [1,2,3,4]
            h: "abc"
            price: 10.99
            max1: 100
            max2: 200
            min1: 50
            min2: 30
        },{
            a: 1
            b: 2
            c: {d: 3, e:4}
            f: (x) -> x * x
            g: [1,2,3,4]
            h: "abc"
            price: 10.99
            max1: 100
            max2: 200
            min1: 50
            min2: 30
        }]
        data = bar.findOne {
            where: {a: 1}
        }
        expect(data.a).to.be(1)
        data = bar.findOne {
            where: {no_val: 11111}
        }
        expect(data.a).not.to.be.ok()
    it "Projection", ->
        bar.drop()
        bar.insert [{
            a: 1
            b: 2
            c: {d: 3, e:4}
            f: (x) -> x * x
            g: [1,2,3,4]
            h: "abc"
            price: 10.99
            max1: 100
            max2: 200
            min1: 50
            min2: 30
        },{
            a: 1
            b: 2
            c: {d: 3, e:4}
            f: (x) -> x * x
            g: [1,2,3,4]
            h: "abc"
            price: 10.99
            max1: 100
            max2: 200
            min1: 50
            min2: 30
        }]
        data = bar.findOne {
            where: {a: 1}
            projection: {a: 1, _id: -1}
        }
        expect(data).to.be.eql({a:1})
        data = bar.find {
            where: {a: 1}
            projection: {"g.$": 1}
        }
        expect(d.g).to.be.eql([1]) for d in data
        data = bar.find {
            where: {b: 1}
            projection: {"g.$": 1}
        }
        expect(data).to.be.eql([])
        data = bar.find {
            where: {a: 1}
            projection: {"a.$": 1}
        }
        expect(data).to.be.eql([])
        bar.drop()
        bar.insert [{
            _id: 1,
            zipcode: "63109",
            students: [
                { name: "john", school: 102, age: 10 },
                { name: "jess", school: 102, age: 11 },
                { name: "jeff", school: 108, age: 15 }
            ]
        }
        {
            _id: 2,
            zipcode: "63110",
            students: [
                { name: "ajax", school: 100, age: 7 },
                { name: "achilles", school: 100, age: 8 },
            ]
        }
        {
            _id: 3,
            zipcode: "63109",
            students: [
                { name: "ajax", school: 100, age: 7 },
                { name: "achilles", school: 100, age: 8 },
            ]
        }
        {
            _id: 4,
            zipcode: "63109",
            students: [
                { name: "barney", school: 102, age: 7 },
                { name: "ruth", school: 102, age: 16 },
            ]
        }]
        data = bar.find {
            where: { zipcode: "63109"}
            projection: {
                _id: 1
                students: {$elemMatch: { school: 102 } }
            }
        }
        console.log data
        data = bar.find {
            where: { zipcode: "63109"}
            projection: {
                _id: 1
                unexist: {$elemMatch: { school: 102 } }
            }
        }
        console.log data



































