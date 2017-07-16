# Tryy
(very) Lightweight framework to make Swift's error catching more "flat"

# The problem

Swift's try-catch model can be messy, especially in terms of scope and for those of us that don't like the extra indent (especially with closures). You might get something like:

```swift
do {
  let foo = try someFunc(num: arg) { result in
    ...
  }
} catch .. {
  ...
} catch .. {

}
// Can't use foo in this scope
```

This framework simplifies everything to one line. It flattens it.

# Quickstart

## tryy(_:)
### Go-like tuple
```swift
let (tupleErr, tupleVal) = tryy { try errorFunc(a: 5) }

// Return early for errors
if let err = tupleErr else {
    return
}

// Use value in same scope
guard let value: String = tupleVal else { return }
```

## tryyWrap(_:)
### As an enum (properties)
```swift
let enumResult = tryyWrap { try errorFunc(a: -3) }

// Return early for errors
if let err = enumResult.error else {
    return
}

// No need to unwrap it if errorFunc(a:) doesn't return an optional
let value: String = enumResult.val

// Optional version
let valueOptional: String = enumResult.value
```

### As an enum (switch)
```swift
let enumResult = tryyWrap { try errorFunc(a: -3) }

// From a switch
switch enumResult {
case .value(let value):
    print(value)
case .error(let err):
    print(err.localizedDescription)
}
```

## Underscores
```swift
let enumResult = __ { try errorFunc(a: 5) }
let (tupleErr, tupleVal) = ___ { try errorFunc(a: 5) }
```

# Warning

Keep in mind you can only ommit `return` and return type on one liners. The block must return the value. In situations like this, the compiler will assume the the return type is Void and you will not end up with a value

```swift
// This WILL NOT work
let tupleResultCompletion = tryy {
    let a = 4 * 2
    try errorFunc(a: a, completion: { (num) -> String in
        return "\(num) * 2 = \(num * 2)"
    })
}

// This WILL work
let tupleResultCompletion = tryy { () -> String? in
    let a = 4 * 2
    return try errorFunc(a: a, completion: { (num) -> String in
        return "\(num) * 2 = \(num * 2)"
    })
}
```

# Example usage

These examples will use this code

```swift
enum TestError: Error {
    case foo
    case bar
}

func errorFunc(a: Int, completion: ((Int)->String)? = nil) throws -> String {
    if a > 0 {
        return completion?(a) ?? "\(a)"
    } else {
        throw TestError.foo
    }
}
```

### Old way

```swift
do {
    let strResult = try errorFunc(a: -4, completion: { (num) -> String in
        return "\(num) + 4 = \(num + 4)"
    })
} catch let error as TestError {
    switch error {
    case .foo:
        print("Foo error")
    case .bar:
        print("Bar error")
    }
}
```

### Tuple examples

```swift
    // Go-like: Return a tuple of an error and value
    let (tupleErr, tupleVal) = tryy { try errorFunc(a: 5) }
    
    // Return early for errors
    if let err = tupleErr {
        return
    }
    
    // Use value in same scope
    guard let value: String = tupleVal else { return }
```

```swift
    // Discard: works like try?
    let (_, tupleVal) = tryy { try errorFunc(a: 5) }
    
    // Use value in same scope
    guard let value: String = tupleVal else { return }
```

```swift
    let tupleResultCompletion = tryy {
        try errorFunc(a: 3, completion: { (num) -> String in
            return "\(num) * 2 = \(num * 2)"
        })
    }
```

### Enum examples

```swift
    // Enum switch
    let enumResult = tryyWrap { try errorFunc(a: -3) }
    
    switch enumResult {
    case .value(let value):
        print(value)
    case .error(let err):
        print(err.localizedDescription)
    }
```

```swift
    // Enum direct
    let enumResult = tryyWrap { try errorFunc(a: -3) }
    
    let error = enumResult.error
    let valueOpt: String? = enumResult.value
```

```swift
    // Enum Go-like: Return an enum of an error and value
    let enumResult = tryyWrap { try errorFunc(a: -3) }
    
    // Return early for errors
    if let err = enumResult.error else {
        return
    }
    
    // No need to unwrap it if errorFunc(a:) doesn't return an optional
    let value: String = enumResult.val
    
    // Optional version
    guard let valueUnwrapped = enumResult.value else { return }
```

```swift
    // Enum guard: like try?
    guard let value = tryyWrap({ try errorFunc(a: -3) }).value else {
        return
    }
```
