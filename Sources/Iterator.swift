//
//  Iterator.swift
//  LevelDB
//
//  Created by Jeremy Jacobson on 9/27/16.
//
//

import Foundation
import CLevelDB

extension LevelDB {
    public class Iterator: IteratorProtocol {
        public typealias Element = (String, String)
        
        var db: LevelDB
        var iterPtr: OpaquePointer
        var optionsPtr: OpaquePointer
        var upperBound: String?
        
        public init(db: LevelDB, readOptions: [ReadOption] = [], upperBound: String? = nil) {
            self.db = db
            self.upperBound = upperBound
            self.optionsPtr = ReadOptions(from: readOptions).toOpaque()!
            self.iterPtr = leveldb_create_iterator(db.dbPtr, self.optionsPtr)
            leveldb_iter_seek_to_first(self.iterPtr)
        }
        
        public func next() -> (String, String)? {
            if leveldb_iter_valid(self.iterPtr) == 0 {
                return nil
            }
            
            var keyLength: Int = 0
            var valueLength: Int = 0
            let keyCString = leveldb_iter_key(self.iterPtr, &keyLength)!
            let valueCString = leveldb_iter_value(self.iterPtr, &valueLength)!
            
            let pair = (String(cString: keyCString), String(cString: valueCString))
            if let upperBound = self.upperBound, upperBound <= pair.0 {
                return nil
            }
            
            leveldb_iter_next(self.iterPtr)
            return pair
        }
        
        public func seek(toKey key: String) {
            leveldb_iter_seek(self.iterPtr, key, key.utf8CString.count)
        }
        
        deinit {
            leveldb_iter_destroy(self.iterPtr)
            leveldb_readoptions_destroy(self.optionsPtr)
        }
    }

}
