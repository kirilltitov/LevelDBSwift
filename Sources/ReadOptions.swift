//
//  ReadOptions.swift
//  LevelDB
//
//  Created by Jeremy Jacobson on 9/27/16.
//
//

import Foundation
import CLevelDB

public enum ReadOption {
    case verifyChecksums(Bool)
    case fillCache(Bool)
}

public class ReadOptions {
    var verifyChecksums: Bool = false
    var fillCache: Bool = false
    
    public init(from options: [ReadOption]) {
        for option in options {
            switch option {
            case .fillCache(let f):
                self.fillCache = f
            case .verifyChecksums(let v):
                self.verifyChecksums = v
            }
        }
    }
    
    internal func toOpaque() -> OpaquePointer? {
        guard let optionsPtr = leveldb_readoptions_create() else {
            return nil
        }
        
        leveldb_readoptions_set_fill_cache(optionsPtr, self.fillCache ? 1 : 0)
        leveldb_readoptions_set_verify_checksums(optionsPtr, self.verifyChecksums ? 1 : 0)
        
        return optionsPtr
    }
}
