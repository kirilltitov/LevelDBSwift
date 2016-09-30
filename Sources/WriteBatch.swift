//
//  WriteBatch.swift
//  LevelDB
//
//  Created by Jeremy Jacobson on 9/28/16.
//
//

import Foundation
import CLevelDB

public class WriteBatch {
    internal var ptr: OpaquePointer
    
    public init() {
        self.ptr = leveldb_writebatch_create()
    }
    
    public func put(key: String, value: String) {
        leveldb_writebatch_put(self.ptr, key, key.utf8CString.count, value, value.utf8CString.count)
    }
    
    public func put(key: String, value: Data) throws {
        let valStr = try decodeUTF8(value)
        self.put(key: key, value: valStr)
    }
    
    public func put(key: Data, value: Data) throws {
        let keyStr = try decodeUTF8(key)
        let valStr = try decodeUTF8(value)
        self.put(key: keyStr, value: valStr)
    }
    
    public func delete(key: String) {
        leveldb_writebatch_delete(self.ptr, key, key.utf8CString.count)
    }
    
    public func delete(key: Data) throws {
        let keyStr = try decodeUTF8(key)
        self.delete(key: keyStr)
    }
    
    public func clear() {
        leveldb_writebatch_clear(self.ptr)
    }
    
    deinit {
        leveldb_writebatch_destroy(self.ptr)
    }
}
