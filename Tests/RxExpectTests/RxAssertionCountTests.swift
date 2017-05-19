//
//  RxAssertionCountTests.swift
//  RxExpect
//
//  Created by Suyeol Jeon on 20/05/2017.
//
//

import XCTest
import RxSwift
import RxTest
import RxExpect

final class RxAssertionCountTests: XCTestCase {
  func testAssertCount() {
    RxExpect("it should assert count") { test in
      let result = watch(test)
      let source = PublishSubject<Int>()
      test.input(source, [next(100, 1), next(200, 2), completed(300)])
      test.assert(source).count(3)
      XCTAssertTrue(result.isPassed)
    }

    RxExpect("it should fail assert count") { test in
      let result = watch(test)
      let source = PublishSubject<Int>()
      test.input(source, [next(100, 1), next(200, 2), completed(300)])
      test.assert(source).count(2)
      XCTAssertFalse(result.isPassed)
    }
  }

  func testAssertCount_empty() {
    RxExpect("it should assert count of empty source") { test in
      let result = watch(test)
      let source = PublishSubject<Int>()
      test.input(source, [])
      test.assert(source).count(0)
      XCTAssertTrue(result.isPassed)
    }

    RxExpect("it should fail assert count of empty source") { test in
      let result = watch(test)
      let source = PublishSubject<Int>()
      test.input(source, [])
      test.assert(source).count(1)
      XCTAssertFalse(result.isPassed)
    }
  }

  func testAssertCount_filtered() {
    RxExpect("it should assert count of filtered source") { test in
      let result = watch(test)
      let source = PublishSubject<Int>()
      test.input(source, [next(100, 1), next(200, 2), completed(300)])
      test.assert(source).filterNext().since(200).count(1)
      XCTAssertTrue(result.isPassed)
    }

    RxExpect("it should fail assert count of filtered source") { test in
      let result = watch(test)
      let source = PublishSubject<Int>()
      test.input(source, [next(100, 1), next(200, 2), completed(300)])
      test.assert(source).filterNext().since(200).count(3)
      XCTAssertFalse(result.isPassed)
    }
  }
}
