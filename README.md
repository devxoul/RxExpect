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
/// define classes for each view models
final class ArticleDetailViewModelTests: RxTestCase {

    /// define functions for each outputs
    func testLikeButtonSelected() {

        // define expectations for each inputs
        RxExpect("like button should become selected when like button tapped") { test in
            let viewModel = ArticleDetailViewModel()

            // providing an initial state: currently not marked as 'liked'
            test.input(viewModel.liked, [
                next(0, false),
            ])

            // providing an user input: user tapped like button
            test.input(viewModel.likeButtonDidTap, [
                next(1, Void()),
            ])

            // test output: like button become selected
            test.assertEqual(viewModel.likeButtonSelected, [
                next(true),
            ])
        }
        
        RxExpect("like button should become unselected when like button tapped") { test in
            let viewModel = ArticleDetailViewModel()

            // providing an initial state: already marked as 'liked'
            test.input(viewModel.liked, [
                next(0, true),
            ])

            // providing an user input: user tapped like button
            test.input(viewModel.likeButtonDidTap, [
                next(1, Void()),
            ])

            // test output: like button become selected
            test.assertEqual(viewModel.likeButtonSelected, [
                next(false),
            ])
        }
    }

}
```
