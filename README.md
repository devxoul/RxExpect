RxExpect
========

![Swift](https://img.shields.io/badge/Swift-3.0-orange.svg)
[![Build Status](https://travis-ci.org/devxoul/RxExpect.svg?branch=master)](https://travis-ci.org/devxoul/RxExpect)
[![CocoaPods](http://img.shields.io/cocoapods/v/RxExpect.svg)](https://cocoapods.org/pods/RxExpect)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

RxExpect is a testing framework for RxSwift.

## Concept

Provide inputs then test outputs. This is an example code that tests `map()` operator multiplying the values by 2.

```swift
func testMultiply() {
  RxExpect("it should multiply values by 2") { test in
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
    test.assertEqual(result, [
      next(2),
      next(4),
      next(6),
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
final class ArticleDetailViewModelTests: RxTestCase {

  func testLikeButtonSelected() {
    RxExpect("like button should become selected when like button tapped") { test in
      let viewModel = ArticleDetailViewModel()

      // providing an user input: user tapped like button
      test.input(viewModel.likeButtonDidTap, [
        next(100, Void()), // next(time, value)
      ])

      // test output: like button become selected
      test.assertEqual(viewModel.likeButtonSelected, [
        next(false), // initial state
        next(true),  // should become true
      ])
    }
    
    RxExpect("like button should become unselected when like button tapped") { test in
      let viewModel = ArticleDetailViewModel()

      // providing an user input: user tapped like button
      test.input(viewModel.likeButtonDidTap, [
        next(100, Void()),
      ])

      // test output: like button become selected
      test.assertEqual(viewModel.likeButtonSelected, [
        next(true),  // initial state
        next(false), // should become false
      ])
    }
  }

}
```

## Examples

* [RxTodo](https://github.com/devxoul/RxTodo/tree/master/RxTodoTests/Sources/Tests)

## APIs

#### Providing Inputs

* `input(observer, events)`
* `input(variable, events)`

#### Assert Equal

* `assertEqual(source, expectedEvents)`
* `assertNextEqual(source, expectedEvents)`
* `assertNextEqual(source, expectedElements)`

#### Assert Not Equal

* `assertNotEqual(source, expectedEvents)`
* `assertNextNotEqual(source, expectedEvents)`
* `assertNextNotEqual(source, expectedElements)`

## Installation

- **For iOS 8+ projects** with [CocoaPods](https://cocoapods.org):

    ```ruby
    pod 'RxExpect', '~> 0.1'
    ```

- **For iOS 8+ projects** with [Carthage](https://github.com/Carthage/Carthage):

    ```
    github "devxoul/RxExpect" ~> 0.1
    ```

- **For iOS 7 projects** with [CocoaSeeds](https://github.com/devxoul/CocoaSeeds):

    ```ruby
    github 'devxoul/RxExpect', '0.1.2', :files => 'Sources/*.swift'
    ```

## License

RxExpect is under MIT license. See the [LICENSE](LICENSE) file for more info.
