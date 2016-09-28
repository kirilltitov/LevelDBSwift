LevelDBSwift
============
![macOS](https://img.shields.io/badge/os-macOS-green.svg)
![Linux](https://img.shields.io/badge/os-Linux-green.svg)
![Swift](https://img.shields.io/badge/swift-3.0-orange.svg)
![License](https://img.shields.io/badge/license-MIT-blue.svg)

A [LevelDB](https://github.com/google/leveldb) library for Swift!

## Usage
```swift
import LevelDB

let db = try! LevelDB(path: "/tmp/leveldb_test")
try! db.put(key: "0", "hello")
let v = try! db.get(key: "0")
print(v) // "hello"
try! db.delete(key: "0")
db.close()
```

## Installing LevelDB
On Mac: `brew install leveldb`

On Linux: `apt-get install libleveldb-dev`

## Building
You should be able to just run: `swift build`

But if you have issues trying to find the leveldb headers and libary:

```bash
swift build -Xcc -I/usr/local/include -Xlinker -L/usr/local/lib
```

## Testing
From the command line run: `swift test` or generate an Xcode project with `swift package generate-xcodeproj` and run the tests there.

## License
MIT