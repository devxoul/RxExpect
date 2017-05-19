//
//  RxAssertionContainTests.swift
//  RxExpect
//
//  Created by Suyeol Jeon on 25/01/2017.
//  Copyright © 2017 Suyeol Jeon. All rights reserved.
//

import XCTest
import RxSwift
import RxTest
import RxExpect

final class RxAssertionContainTests: XCTestCase {

  func testAssertContainOfNonEquatable() {
    RxExpect("it should assert contain of non equatable events", run: false) { test in
      let source = PublishSubject<NonEquatable>()
      test.input(source, [
        next(100, NonEquatable(name: "A")),
        next(200, NonEquatable(name: "B")),
      ])
      test.assert(source).contains { event in
        event.value.element?.name == "B"
      }
      test.assert(source).contains { event in
        event.value.element?.name == "C"
      }
      test.run { XCTAssertEqual($0, [true, false]) }
    }
  }

  func testAssertNotContainOfNonEquatable() {
    RxExpect("it should assert not contain of non equatable events", run: false) { test in
      let source = PublishSubject<NonEquatable>()
      test.input(source, [
        next(100, NonEquatable(name: "A")),
        next(200, NonEquatable(name: "B")),
      ])
      test.assert(source).not().contains { event in
        event.value.element?.name == "C"
      }
      test.assert(source).not().contains { event in
        event.value.element?.name == "B"
      }
      test.run { XCTAssertEqual($0, [true, false]) }
    }
  }

  func testAssertContainOfEquatable() {
    RxExpect("it should assert contain of equatable events", run: false) { test in
      let source = PublishSubject<String>()
      test.input(source, [
        next(100, "A"),
        next(200, "B"),
      ])
      test.assert(source).contains(next(100, "A"))
      test.assert(source).contains(next(100, "C"))
      test.run { XCTAssertEqual($0, [true, false]) }
    }

    RxExpect("it should assert contain of equatable elements", run: false) { test in
      let source = PublishSubject<String>()
      test.input(source, [
        next(100, "A"),
        next(200, "B"),
      ])
      test.assert(source).contains("A")
      test.assert(source).contains("C")
      test.run { XCTAssertEqual($0, [true, false]) }
    }
  }

  func testAssertNotContainOfEquatable() {
    RxExpect("it should assert not contain of equatable events with different element", run: false) { test in
      let source = PublishSubject<String>()
      test.input(source, [
        next(100, "A"),
        next(200, "B"),
      ])
      test.assert(source).not().contains(next(100, "C"))
      test.assert(source).not().contains(next(100, "A"))
      test.run { XCTAssertEqual($0, [true, false]) }
    }

    RxExpect("it should assert not contain of equatable events with different time", run: false) { test in
      let source = PublishSubject<String>()
      test.input(source, [
        next(100, "A"),
        next(200, "B"),
      ])
      test.assert(source).not().contains(next(200, "A"))
      test.assert(source).not().contains(next(200, "B"))
      test.run { XCTAssertEqual($0, [true, false]) }
    }

    RxExpect("it should assert not contain of equatable elements", run: false) { test in
      let source = PublishSubject<String>()
      test.input(source, [
        next(100, "A"),
        next(200, "B"),
      ])
      test.assert(source).not().contains("a")
      test.assert(source).not().contains("A")
      test.run { XCTAssertEqual($0, [true, false]) }
    }
  }

}
