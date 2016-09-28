//
//  LevelDB+Subscript.swift
//  LevelDB
//
//  Created by Jeremy Jacobson on 9/28/16.
//
//

import Foundation

extension LevelDB {
    public struct Slice: Sequence {
        public typealias Iterator = LevelDB.Iterator
        
        let db: LevelDB
        let range: Range<String>
        
        public func makeIterator() -> LevelDB.Iterator {
            let iterator = LevelDB.Iterator(db: self.db, upperBound: self.range.upperBound)
            iterator.seek(toKey: self.range.lowerBound)
            return iterator
        }
        
        public func contains(key: String) -> Bool {
            return self.range.contains(key)
        }
    }
    
    public subscript(key: String) -> String? {
        get {
            return try! self.get(key: key)
        }
        
        set(value) {
            // note: if the write fails, it is silent
            try! self.put(key: key, value: value ?? "")
        }
    }
    
    public subscript(range: Range<String>) -> Slice {
        return Slice(db: self, range: range)
    }
}
