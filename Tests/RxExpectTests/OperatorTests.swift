//
//  OperatorTests.swift
//  RxExpect
//
//  Created by Suyeol Jeon on 20/05/2017.
//
//

import XCTest
import RxSwift
import RxTest
import RxExpect

class OperatorTests: XCTestCase {
  private struct TestError: Error {}

  func testInequalityOperator() {
    XCTAssertEqual(
      Event<Int>.next(1) != Event<Int>.next(1),
      !(Event<Int>.next(1) == Event<Int>.next(1))
    )
    XCTAssertEqual(
      Event<Int>.next(1) != Event<Int>.next(2),
      !(Event<Int>.next(1) == Event<Int>.next(2))
    )
    XCTAssertEqual(
      Event<Int>.next(1) != Event<Int>.error(TestError()),
      !(Event<Int>.next(1) == Event<Int>.error(TestError()))
    )
    XCTAssertEqual(
      Event<Int>.next(1) != Event<Int>.completed,
      !(Event<Int>.next(1) == Event<Int>.completed)
    )

    XCTAssertEqual(
      Event<Int>.error(TestError()) != Event<Int>.error(TestError()),
      !(Event<Int>.error(TestError()) == Event<Int>.error(TestError()))
    )
    XCTAssertEqual(
      Event<Int>.error(TestError()) != Event<Int>.completed,
      !(Event<Int>.error(TestError()) == Event<Int>.completed)
    )

    XCTAssertEqual(
      Event<Int>.completed != Event<Int>.completed,
      !(Event<Int>.completed == Event<Int>.completed)
    )
  }
}
