//
//  FilterPolicy.swift
//  LevelDB
//
//  Created by Jeremy Jacobson on 9/28/16.
//
//

import Foundation
import CLevelDB

public class FilterPolicy {
    let pointer: OpaquePointer
    
    init(pointer: OpaquePointer) {
        self.pointer = pointer
    }
    
    public static func bloomFilter(bitsPerKey: Int) -> FilterPolicy? {
        guard let bloomFilterPtr = leveldb_filterpolicy_create_bloom(Int32(bitsPerKey)) else {
            return nil
        }
        
        return FilterPolicy(pointer: bloomFilterPtr)
    }
    
    deinit {
        leveldb_filterpolicy_destroy(self.pointer)
    }
}
