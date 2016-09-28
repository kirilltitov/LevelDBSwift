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
    
    public func delete(key: String) {
        leveldb_writebatch_delete(self.ptr, key, key.utf8CString.count)
    }
    
    public func clear() {
        leveldb_writebatch_clear(self.ptr)
    }
    
    deinit {
        leveldb_writebatch_destroy(self.ptr)
    }
}
