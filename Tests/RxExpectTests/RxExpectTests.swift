import XCTest
import RxSwift
import RxTest
import RxExpect

final class RxExpectTests: XCTestCase {
  func testAssertionClosureExecutes() {
    var executions: [String] = []
    _ = {
      let test = RxExpect()
      let source = PublishSubject<String>()
      test.input(source, [next(100, "A"), next(200, "B")])
      test.assert(source) { _ in executions.append("1") }
      test.assert(source) { _ in executions.append("2") }
      test.assert(source) { _ in executions.append("3") }
    }()
    XCTAssertEqual(executions, ["1", "2", "3"])
  }

  func testAssertEvents() {
    let test = RxExpect()
    let subject = PublishSubject<String>()
    test.input(subject, [
      next(100, "A"),
      next(200, "B"),
      completed(300),
    ])
    test.assert(subject) { events in
      XCTAssertEqual(events, [
        next(100, "A"),
        next(200, "B"),
        completed(300),
      ])
    }

    let variable = Variable<Int>(0)
    test.input(variable, [
      next(300, 1),
      next(400, 2),
      next(500, 3),
    ])
    test.assert(variable.asObservable()) { events in
      XCTAssertEqual(events, [
        next(0, 0),
        next(300, 1),
        next(400, 2),
        next(500, 3),
      ])
    }
  }

  func testNotRetain() {
    weak var object: NSObject?
    _ = {
      object = NSObject()
    }()
    XCTAssertNil(object)
  }

  func testRetain() {
    let test = RxExpect()
    weak var object: NSObject?
    _ = {
      object = test.retain(NSObject())
    }()
    XCTAssertNotNil(object)
  }
}
