//
//  WriteOptions.swift
//  LevelDB
//
//  Created by Jeremy Jacobson on 9/27/16.
//
//

import Foundation
import CLevelDB

public enum WriteOption {
    case sync(Bool)
}

public class WriteOptions {
    var sync: Bool = true
    
    public init(from options: [WriteOption]) {
        for option in options {
            switch option {
            case .sync(let sync):
                self.sync = sync
            }
        }
    }
    
    internal func toOpaque() -> OpaquePointer? {
        guard let optionsPtr = leveldb_writeoptions_create() else {
            return nil
        }
        
        leveldb_writeoptions_set_sync(optionsPtr, self.sync ? 1 : 0)
        
        return optionsPtr
    }
}
