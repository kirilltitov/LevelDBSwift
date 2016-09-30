//
//  LevelDB.swift
//  LevelDB
//
//  Created by Jeremy Jacobson on 9/26/16.
//
//

import Foundation
import CLevelDB

func encodeUTF8(_ string: String) throws -> Data {
    guard let data = string.data(using: .utf8) else {
        throw LevelDB.DBError(message: "Could not encode string to utf8.")
    }
    
    return data
}

func decodeUTF8(_ data: Data) throws -> String {
    guard let str = String(data: data, encoding: .utf8) else {
        throw LevelDB.DBError(message: "Could not decode string from utf8.")
    }
    
    return str
}

public class LevelDB: Sequence {
    public struct DBError: Error {
        var message: String
        public var localizedDescription: String {
            return self.message
        }
    }
    
    internal var optionsPtr: OpaquePointer?
    internal var dbPtr: OpaquePointer
    
    public var path: String
    public var options: Options
    public var closed: Bool = true
    
    public init(path: String, options: [Option] = []) throws {
        self.path = path
        self.options = Options(from: options)
        guard let optionsPtr = self.options.toOpaque() else {
            throw DBError(message: "Could not create options.")
        }
        
        var errorPtr: UnsafeMutablePointer<CChar>?
        guard let dbPtr = leveldb_open(optionsPtr, path, &errorPtr) else {
            var message: String
            if let error = errorPtr {
                message = String(cString: UnsafePointer(error))
            } else {
                message = "Unknown error opening."
            }
            
            throw DBError(message: message)
        }
        
        self.closed = false
        self.dbPtr = dbPtr
        self.optionsPtr = optionsPtr
    }
    
    public func get(key: String, readOptions: [ReadOption] = []) throws -> String? {
        try self.verifyOpen()
        
        guard let optionsPtr = ReadOptions(from: readOptions).toOpaque() else {
            throw DBError(message: "Could not create read options.")
        }
        var errorPtr: UnsafeMutablePointer<CChar>?
        var valueLen: Int = 0

        let value = leveldb_get(self.dbPtr, optionsPtr, key, key.utf8CString.count, &valueLen, &errorPtr)
        if let error = errorPtr {
            let message = String(cString: UnsafePointer(error))
            throw DBError(message: "Could not get value for \"\(key)\": \(message)")
        }
        
        leveldb_readoptions_destroy(optionsPtr)
        if value == nil {
            return nil
        }
        
        return String(cString: UnsafePointer(value!))
    }
    
    public func get(key: Data, readOptions: [ReadOption] = []) throws -> Data? {
        let keyStr = try decodeUTF8(key)
        
        guard let valueStr = try self.get(key: keyStr, readOptions: readOptions) else {
            return nil
        }
        
        return try encodeUTF8(valueStr)
    }
    
    public func put(key: String, value: String, writeOptions: [WriteOption] = []) throws {
        try self.verifyOpen()
        
        guard let optionsPtr = WriteOptions(from: writeOptions).toOpaque() else {
            throw DBError(message: "Could not create write options.")
        }
        
        var errorPtr: UnsafeMutablePointer<CChar>?
        
        leveldb_put(self.dbPtr, optionsPtr, key, key.utf8CString.count, value, value.utf8CString.count, &errorPtr)
        leveldb_writeoptions_destroy(optionsPtr)
        
        if let error = errorPtr {
            let message = String(cString: UnsafePointer(error))
            throw DBError(message: "Could not get value for \"\(key)\": \(message)")
        }
    }
    
    public func put(key: String, value: Data, writeOptions: [WriteOption] = []) throws {
        let valStr = try decodeUTF8(value)
        
        try self.put(key: key, value: valStr, writeOptions: writeOptions)
    }
    
    public func put(key: Data, value: Data, writeOptions: [WriteOption] = []) throws {
        let keyStr = try decodeUTF8(key)
        let valStr = try decodeUTF8(value)
        
        try self.put(key: keyStr, value: valStr, writeOptions: writeOptions)
    }
    
    public func delete(key: String, writeOptions: [WriteOption] = []) throws {
        try self.verifyOpen()
        
        guard let optionsPtr = WriteOptions(from: writeOptions).toOpaque() else {
            throw DBError(message: "Could not create write options.")
        }
        
        var errorPtr: UnsafeMutablePointer<CChar>?
        
        leveldb_delete(self.dbPtr, optionsPtr, key, key.utf8CString.count, &errorPtr)
        leveldb_writeoptions_destroy(optionsPtr)
        
        if let error = errorPtr {
            let message = String(cString: UnsafePointer(error))
            throw DBError(message: "Could not delete \"\(key)\": \(message)")
        }
    }
    
    public func delete(key: Data, writeOptions: [WriteOption] = []) throws {
        let keyStr = try decodeUTF8(key)
        
        try self.delete(key: keyStr, writeOptions: writeOptions)
    }
    
    public func write(batch: WriteBatch, writeOptions: [WriteOption] = []) throws {
        try self.verifyOpen()
        
        guard let optionsPtr = WriteOptions(from: writeOptions).toOpaque() else {
            throw DBError(message: "Could not create write options.")
        }
        
        var errorPtr: UnsafeMutablePointer<CChar>?
        leveldb_write(self.dbPtr, optionsPtr, batch.ptr, &errorPtr)
        
        if let error = errorPtr {
            let message = String(cString: UnsafePointer(error))
            throw DBError(message: "Could not write batch: \(message)")
        }
    }
    
    public func destroy() throws {
        if !self.closed {
            self.close()
        }
        
        var errorPtr: UnsafeMutablePointer<CChar>?
        var optionsPtr: OpaquePointer
        if self.optionsPtr != nil {
            optionsPtr = self.optionsPtr!
        } else {
            optionsPtr = leveldb_options_create()
        }
        
        leveldb_destroy_db(optionsPtr, self.path, &errorPtr)
        if let error = errorPtr {
            let message = String(cString: UnsafePointer(error))
            throw DBError(message: "Could not destroy database: \(message)")
        }
    }
    
    public func close() {
        if self.closed {
            return
        }
        
        leveldb_close(self.dbPtr)
        self.closed = true
    }
    
    public func makeIterator() -> LevelDB.Iterator {
        return Iterator(db: self)
    }
    
    private func verifyOpen() throws {
        if self.closed {
            throw DBError(message: "Cannot write to closed database.")
        }
    }
    
    deinit {
        if !self.closed {
            self.close()
        }
        
        if let optionsPtr = self.optionsPtr {
            leveldb_options_destroy(optionsPtr)
        }
    }
}
