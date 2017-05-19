//
//  RxAssertionEmptyTests.swift
//  RxExpect
//
//  Created by Suyeol Jeon on 25/01/2017.
//  Copyright © 2017 Suyeol Jeon. All rights reserved.
//

import XCTest
import RxSwift
import RxTest
import RxExpect

final class RxAssertionEmptyTests: XCTestCase {

  func testAssertEmpty() {
    RxExpect("it should assert emptiness", run: false) { test in
      let source = PublishSubject<Int>()
      test.input(source, [])
      test.assert(source).isEmpty()
      test.run { XCTAssertEqual($0, [true]) }
    }

    RxExpect("it should fail assert emptiness", run: false) { test in
      let source = PublishSubject<Int>()
      test.input(source, [next(100, 1)])
      test.assert(source).isEmpty()
      test.run { XCTAssertEqual($0, [false]) }
    }
  }

  func testAssertNotEmpty() {
    RxExpect("it should assert non-emptiness", run: false) { test in
      let source = PublishSubject<Int>()
      test.input(source, [next(100, 1)])
      test.assert(source).not().isEmpty()
      test.run { XCTAssertEqual($0, [true]) }
    }

    RxExpect("it should assert fail non-emptiness", run: false) { test in
      let source = PublishSubject<Int>()
      test.input(source, [])
      test.assert(source).not().isEmpty()
      test.run { XCTAssertEqual($0, [false]) }
    }
  }

}
