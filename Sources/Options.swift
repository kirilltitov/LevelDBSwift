//
//  Options.swift
//  LevelDB
//
//  Created by Jeremy Jacobson on 9/27/16.
//
//

import Foundation
import CLevelDB

public enum Compression: Int32 {
    case none = 0
    case snappy = 1
}

public enum Option {
    case filterPolicy(FilterPolicy)
    case createIfMissing(Bool)
    case errorIfExists(Bool)
    case paranoidChecks(Bool)
    case writeBufferSize(Int)
    case maxOpenFiles(Int32)
    case cacheCapacity(Int)
    case blockSize(Int)
    case blockRestartInterval(Int32)
    case compression(Compression)
}

public class Options {
    var filterPolicy: FilterPolicy? = nil
    var createIfMissing: Bool = false
    var errorIfExists: Bool = false
    var paranoidChecks: Bool = false
    var writeBufferSize: Int = 4 << 20 // 4MB
    var maxOpenFiles: Int32 = 1000
    var cacheCapacity: Int = -1
    var blockSize: Int = 4096
    var blockRestartInterval: Int32 = 16
    var compression: Compression = .snappy
    
    var cachePtr: OpaquePointer?
    
    public init(from options: [Option]) {
        for option in options {
            switch option {
            case .filterPolicy(let filterPolicy):
                self.filterPolicy = filterPolicy
            case .createIfMissing(let create):
                self.createIfMissing = create
            case .errorIfExists(let error):
                self.errorIfExists = error
            case .paranoidChecks(let checks):
                self.paranoidChecks = checks
            case .writeBufferSize(let size):
                self.writeBufferSize = size
            case .maxOpenFiles(let max):
                self.maxOpenFiles = max
            case .blockSize(let size):
                self.blockSize = size
            case .blockRestartInterval(let interval):
                self.blockRestartInterval = interval
            case .compression(let c):
                self.compression = c
            case .cacheCapacity(let capacity):
                self.cacheCapacity = capacity
            }
        }
    }
    
    internal func toOpaque() -> OpaquePointer? {
        guard let optionsPtr = leveldb_options_create() else {
            return nil
        }
        
        leveldb_options_set_create_if_missing(optionsPtr, self.createIfMissing ? 1 : 0)
        leveldb_options_set_error_if_exists(optionsPtr, self.errorIfExists ? 1 : 0)
        leveldb_options_set_paranoid_checks(optionsPtr, self.paranoidChecks ? 1 : 0)
        leveldb_options_set_write_buffer_size(optionsPtr, self.writeBufferSize)
        leveldb_options_set_max_open_files(optionsPtr, self.maxOpenFiles)
        leveldb_options_set_block_size(optionsPtr, self.blockSize)
        leveldb_options_set_block_restart_interval(optionsPtr, self.blockRestartInterval)
        leveldb_options_set_compression(optionsPtr, self.compression.rawValue)
        if self.cacheCapacity != -1, let cache = leveldb_cache_create_lru(self.cacheCapacity) {
            self.cachePtr = cache
            leveldb_options_set_cache(optionsPtr, cache)
        }
        
        if let filterPolicy = self.filterPolicy {
            leveldb_options_set_filter_policy(optionsPtr, filterPolicy.pointer)
        }
        
        return optionsPtr
    }
    
    deinit {
        if let cachePtr = self.cachePtr {
            leveldb_cache_destroy(cachePtr)
        }
    }
}
