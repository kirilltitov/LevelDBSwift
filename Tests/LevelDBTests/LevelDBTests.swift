import Foundation
import XCTest
@testable import LevelDB

class LevelDBTests: XCTestCase {
    
    static let testDirectory = "/tmp/leveldb_tests"
    static var allTests: [(String, (LevelDBTests) -> () throws -> Void)] {
        return [
            ("testPut", testPut),
            ("testGet", testGet),
            ("testDelete", testDelete),
            ("testWriteBatch", testWriteBatch),
            ("testIteration", testIteration)
        ]
    }
    
    override class func setUp() {
        do {
            try FileManager.default.createDirectory(atPath: LevelDBTests.testDirectory, withIntermediateDirectories: true, attributes: nil)
        } catch let error {
            XCTFail("Could not create test directory: \(error.localizedDescription)")
        }
    }
    
    override class func tearDown() {
        do {
            try FileManager.default.removeItem(atPath: LevelDBTests.testDirectory)
        } catch let error {
            XCTFail("Could not remove test directory: \(error.localizedDescription)")
        }
    }
    
    func testPut() {
        do {
            let db = try LevelDB(path: "/tmp/leveldb_tests/testPut", options: [.createIfMissing(true)])
            
            try db.put(key: "Hello", value: "world")
            guard let value = try db.get(key: "Hello") else {
                XCTFail("Put failed: `value` for \"world\" is nil")
                return
            }
            
            XCTAssertEqual(value, "world")
            
            try db.destroy()
        } catch let error {
            var message: String
            if let dbError = error as? LevelDB.DBError {
                message = dbError.localizedDescription
            } else {
                message = error.localizedDescription
            }
            
            XCTFail("Put failed: \(message)")
        }
    }
    
    func testGet() {
        do {
            let db = try LevelDB(path: "/tmp/leveldb_tests/testGet", options: [.createIfMissing(true)])
            
            try db.put(key: "Get me!", value: "2", writeOptions: [.sync(true)])
            guard let value = try db.get(key: "Get me!") else {
                XCTFail("Get failed: `value` for \"Get me!\" is nil")
                return
            }
            XCTAssertEqual(value, "2")
            
            try db.delete(key: "Get me!", writeOptions: [.sync(true)])
            
            // "Dummy" should not exist
            let dummy = try db.get(key: "Dummy")
            XCTAssertNil(dummy)
            
            try db.destroy()
        } catch let error {
            var message: String
            if let dbError = error as? LevelDB.DBError {
                message = dbError.localizedDescription
            } else {
                message = error.localizedDescription
            }
            
            XCTFail("Get failed: \(message)")
        }
    }
    
    func testDelete() {
        do {
            let db = try LevelDB(path: "/tmp/leveldb_tests/testDelete", options: [.createIfMissing(true)])
            
            try db.put(key: "Please delete", value: "1", writeOptions: [.sync(true)])
            try db.delete(key: "Please delete", writeOptions: [.sync(true)])
            let value = try db.get(key: "Please delete")
            XCTAssertNil(value)
            
            try db.destroy()
        } catch let error {
            var message: String
            if let dbError = error as? LevelDB.DBError {
                message = dbError.localizedDescription
            } else {
                message = error.localizedDescription
            }
            
            XCTFail("Delete failed: \(message)")
        }
    }
    
    func testWriteBatch() {
        do {
            let db = try LevelDB(path: "/tmp/leveldb_tests/testWriteBatch", options: [.createIfMissing(true)])
            
            try db.put(key: "Del", value: "0")
            
            let batch = WriteBatch()
            batch.put(key: "0", value: "zero")
            batch.put(key: "1", value: "one")
            batch.put(key: "2", value: "two")
            batch.delete(key: "Del")
            try db.write(batch: batch, writeOptions: [.sync(true)])
            
            let zero = try db.get(key: "0")
            XCTAssertEqual(zero, "zero")
            
            let one = try db.get(key: "1")
            XCTAssertEqual(one, "one")
            
            let two = try db.get(key: "2")
            XCTAssertEqual(two, "two")
            
            let getMe = try db.get(key: "Del")
            XCTAssertNil(getMe)
            
            // clean up
            let deleteAll = WriteBatch()
            deleteAll.delete(key: "0")
            deleteAll.delete(key: "1")
            deleteAll.delete(key: "2")
            try db.write(batch: deleteAll, writeOptions: [.sync(true)])
            
            try db.destroy()
        } catch let error {
            var message: String
            if let dbError = error as? LevelDB.DBError {
                message = dbError.localizedDescription
            } else {
                message = error.localizedDescription
            }
            
            XCTFail("Write batch failed: \(message)")
        }
    }
    
    func testIteration() {
        do {
            let db = try LevelDB(path: "/tmp/leveldb_tests/testIteration", options: [.createIfMissing(true)])
            
            let batch = WriteBatch()
            batch.put(key: "1", value: "hi")
            batch.put(key: "2", value: "hello")
            batch.put(key: "3", value: "bye")
            try db.write(batch: batch, writeOptions: [.sync(true)])
            
            var count = 0
            for (key, value) in db {
                print("\(key): \(value)")
                count += 1
            }
            
            XCTAssertEqual(count, 3)
            try db.destroy()
        } catch let error {
            var message: String
            if let dbError = error as? LevelDB.DBError {
                message = dbError.localizedDescription
            } else {
                message = error.localizedDescription
            }
            
            XCTFail("Iteration failed: \(message)")
        }
    }
    
    func testGetSubscript() {
        do {
            let db = try LevelDB(path: "/tmp/leveldb_tests/testGetSubscript", options: [.createIfMissing(true)])
            
            try db.put(key: "0", value: "hello")
            
            let value = db["0"]
            XCTAssertNotNil(value)
            XCTAssertEqual(value!, "hello")
            
            try db.destroy()
        } catch let error {
            var message: String
            if let dbError = error as? LevelDB.DBError {
                message = dbError.localizedDescription
            } else {
                message = error.localizedDescription
            }
            
            XCTFail("Get subscript: \(message)")
        }
    }
    
    func testSetSubscript() {
        do {
            let db = try LevelDB(path: "/tmp/leveldb_tests/testSetSubscript", options: [.createIfMissing(true)])
            
            db["0"] = "hello"
            
            let value = try db.get(key: "0")
            XCTAssertNotNil(value)
            XCTAssertEqual(value!, "hello")
            
            try db.destroy()
        } catch let error {
            var message: String
            if let dbError = error as? LevelDB.DBError {
                message = dbError.localizedDescription
            } else {
                message = error.localizedDescription
            }
            
            XCTFail("Set subscript failed: \(message)")
        }
    }
    
    func testRangeSubscript() {
        do {
            let db = try LevelDB(path: "/tmp/leveldb_tests/testGetSubscript", options: [.createIfMissing(true)])
            
            let writeBatch = WriteBatch()
            writeBatch.put(key: "0", value: "zero")
            writeBatch.put(key: "1", value: "hello")
            writeBatch.put(key: "2", value: "hi")
            writeBatch.put(key: "A", value: "zip")
            try db.write(batch: writeBatch, writeOptions: [.sync(true)])
            
            let slice = db["1"..<"5"]
            var count = 0
            for (key, value) in slice {
                print("\(key): \(value)")
                count += 1
            }
            
            XCTAssertEqual(count, 2)
            try db.destroy()
        } catch let error {
            var message: String
            if let dbError = error as? LevelDB.DBError {
                message = dbError.localizedDescription
            } else {
                message = error.localizedDescription
            }
            
            XCTFail("Iteration failed: \(message)")
        }
    }
}
