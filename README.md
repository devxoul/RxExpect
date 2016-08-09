RxExpect (Draft)
================

![Swift](https://img.shields.io/badge/Swift-2.2-orange.svg)
[![Build Status](https://travis-ci.org/devxoul/RxExpect.svg?branch=master)](https://travis-ci.org/devxoul/RxExpect)
[![CocoaPods](http://img.shields.io/cocoapods/v/RxExpect.svg)](https://cocoapods.org/pods/RxExpect)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

The RxSwift testing framework

## Concept

Provide an input then test an output.

```swift
final class ArticleDetailViewModelTests: RxTestCase {

    func testLikeButtonSelected() {
        RxExpect("like button should become selected when like button tapped") { test in
            let viewModel = ArticleDetailViewModel()

            // providing an user input: user tapped like button
            test.input(viewModel.likeButtonDidTap, [
                next(0, Void()),
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
                next(0, Void()),
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
