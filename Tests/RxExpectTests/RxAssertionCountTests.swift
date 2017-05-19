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
    RxExpect("it should assert count", run: false) { test in
      let source = PublishSubject<Int>()
      test.input(source, [next(100, 1), next(200, 2), completed(300)])
      test.assert(source).count(3)
      test.assert(source).count(2)
      test.run { XCTAssertEqual($0, [true, false]) }
    }
  }

  func testAssertCount_empty() {
    RxExpect("it should assert count of empty source", run: false) { test in
      let source = PublishSubject<Int>()
      test.input(source, [])
      test.assert(source).count(0)
      test.assert(source).count(1)
      test.run { XCTAssertEqual($0, [true, false]) }
    }
  }

  func testAssertCount_filtered() {
    RxExpect("it should assert count of filtered source", run: false) { test in
      let source = PublishSubject<Int>()
      test.input(source, [next(100, 1), next(200, 2), completed(300)])
      test.assert(source).filterNext().since(200).count(1)
      test.assert(source).filterNext().since(200).count(3)
      test.run { XCTAssertEqual($0, [true, false]) }
    }
  }
}
