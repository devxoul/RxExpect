RxExpect
========

![Swift](https://img.shields.io/badge/Swift-5.0-orange.svg)
[![CocoaPods](http://img.shields.io/cocoapods/v/RxExpect.svg)](https://cocoapods.org/pods/RxExpect)
[![Build Status](https://travis-ci.org/devxoul/RxExpect.svg?branch=master)](https://travis-ci.org/devxoul/RxExpect)
[![Codecov](https://img.shields.io/codecov/c/github/devxoul/RxExpect.svg)](https://codecov.io/gh/devxoul/RxExpect/)

RxExpect is a testing framework for RxSwift.

## Concept

Provide inputs then test outputs. This is an example code that tests `map()` operator multiplying the values by 2.

```swift
func testMultiply() {
  let test = RxExpect()
  let value = PublishSubject<Int>()
  let result = value.map { $0 * 2 }

  // provide inputs
  test.input(value, [
    next(100, 1),
    next(200, 2),
    next(300, 3),
    completed(400)
  ])
  
  // test output
  test.assert(result) { events in
    XCTAssertEqual(events, [
      next(100, 2),
      next(200, 4),
      next(300, 6),
      completed(400)
    ])
  }
}
```

It would be easy to understand if you imagine the marble diagram.

```
time   --100-200-300-400 // virtual timeline
value  --1---2---3---|   // provide inputs
result --2---4---6---|   // test these values
```

This is more complicated example.

```swift
final class ArticleDetailViewModelTests: XCTestCase {
  func testLikeButtonSelected() {
    let test = RxExpect()
    let viewModel = ArticleDetailViewModel()
    test.retain(viewModel) // IMPORTANT: prevent from being disposed while testing

    // providing an user input: user tapped like button
    test.input(viewModel.likeButtonDidTap, [
      next(100, Void()),
    ])

    // test output: like button become selected
    test.assert(viewModel.isLikeButtonSelected) { events in
      XCTAssertEqual(events.at(100...).elements, [true])
    }
  }

  func testLikeButtonUnselected() {
    let test = RxExpect()
    let viewModel = ArticleDetailViewModel()
    test.retain(viewModel) // IMPORTANT: prevent from being disposed while testing

    // providing an user input: user tapped like button
    test.input(viewModel.likeButtonDidTap, [
      next(100, Void()),
    ])

    // test output: like button become selected
    test.assert(viewModel.isLikeButtonSelected) { events in
      XCTAssertEqual(events.at(100...).elements, [false])
    }
  }
}
```

## Examples

* [RxTodo](https://github.com/devxoul/RxTodo/tree/master/RxTodoTests/Sources/Tests)
* [Drrrible](https://github.com/devxoul/Drrrible/tree/master/DrrribleTests/Sources)

## APIs

#### Providing Inputs

* `input(observer, events)`
* `input(variable, events)`

#### Start Assertion Chaining

* `assert(source, closure)`

## Installation

- **For iOS 8+ projects** with [CocoaPods](https://cocoapods.org):

    ```ruby
    pod 'RxExpect'
    ```

- **For iOS 8+ projects** with [Carthage](https://github.com/Carthage/Carthage):

    ```
    github "devxoul/RxExpect"
    ```

## Development

```console
$ swift package generate-xcodeproj
$ open RxExpect.xcodeproj
```

## License

RxExpect is under MIT license. See the [LICENSE](LICENSE) file for more info.
