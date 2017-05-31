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

  func testRetain() {
    RxExpect("Test not retain reactor") { test in
      let reactor = TestReactor()
      test.input(reactor.action, [
        next(100, "A"),
        next(200, "B"),
        next(300, "C"),
      ])
      test.assert(reactor.state).isEmpty()
      // when the closure ends, `reactor.state` is disposed because `reactor.disposeBag` is released.
      // then the test will run so `reactor.state` will never emit any elements.
    }

    RxExpect("Test retain reactor") { test in
      let reactor = TestReactor()
      test.retain(reactor)
      test.input(reactor.action, [
        next(100, "A"),
        next(200, "B"),
        next(300, "C"),
      ])
      test.assert(reactor.state).equal(["A", "B", "C"])
    }
  }
}

final class TestReactor {
  var disposeBag = DisposeBag()
  let action = PublishSubject<String>()
  let state: Observable<String>

  init() {
    let state = action.asObservable().replay(1)
    state.connect().disposed(by: self.disposeBag)
    self.state = state
  }
}
