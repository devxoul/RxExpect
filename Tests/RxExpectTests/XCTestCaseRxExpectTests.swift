//
//  XCTestCaseRxExpectTests.swift
//  RxExpect
//
//  Created by Suyeol Jeon on 20/05/2017.
//
//

import XCTest
import RxExpect
import RxTest
import RxSwift

final class XCTestCaseRxExpectTests: XCTestCase {
  func testExpectationRun() {
    let variable = Variable<Int>(0)
    RxExpect("it should run", run: true) { test in
      test.input(variable, [next(100, 1)])
    }
    XCTAssertEqual(variable.value, 1)
  }

  func testExpectationNotRun() {
    let variable = Variable<Int>(0)
    RxExpect("it should not run", run: false) { test in
      test.input(variable, [next(100, 1)])
    }
    XCTAssertEqual(variable.value, 0)
  }

  func testMessage() {
    RxExpect("Test message!!", run: false) { test in
      let observable = Observable<Int>.never()
      test.assert(observable).count(1)
      test.run { results in
        if case .failure(let message, _, _) = results[0] {
          XCTAssertTrue(message.contains("Test message!!"))
        } else {
          XCTFail()
        }
      }
    }
  }
}
