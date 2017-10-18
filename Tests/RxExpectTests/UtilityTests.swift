import XCTest
import RxExpect
import RxSwift
import RxTest

private struct TestError: Error {}

final class UtilityTests: XCTestCase {
  func testElements() {
    let events: [Recorded<Event<String>>] = [
      next(100, "A"),
      next(200, "B"),
      next(300, "C"),
      completed(400),
    ]
    XCTAssertEqual(events.elements, ["A", "B", "C"])
  }

  func testError() {
    let events: [Recorded<Event<String>>] = [
      next(100, "A"),
      next(200, "B"),
      next(300, "C"),
      error(400, TestError()),
    ]
    XCTAssertTrue(events.error is TestError)
  }

  func testFilterNext() {
    let events: [Recorded<Event<String>>] = [
      next(100, "A"),
      next(200, "B"),
      next(300, "C"),
      completed(400),
    ]
    XCTAssertEqual(events.filter(.next), [
      next(100, "A"),
      next(200, "B"),
      next(300, "C"),
    ])
  }

  func testFilterError() {
    let events: [Recorded<Event<String>>] = [
      next(100, "A"),
      next(200, "B"),
      next(300, "C"),
      error(400, TestError()),
    ]
    XCTAssertEqual(events.filter(.error), [
      error(400, TestError()),
    ])
  }

  func testFilterCompleted() {
    let events: [Recorded<Event<String>>] = [
      next(100, "A"),
      next(200, "B"),
      next(300, "C"),
      completed(400),
    ]
    XCTAssertEqual(events.filter(.completed), [
      completed(400),
    ])
  }

  func testFilterByTime() {
    let events: [Recorded<Event<String>>] = [
      next(100, "A"),
      next(200, "B"),
      next(300, "C"),
      completed(400),
    ]
    XCTAssertEqual(events.at(200..<400), [
      next(200, "B"),
      next(300, "C"),
    ])
    XCTAssertEqual(events.at(300...), [
      next(300, "C"),
      completed(400),
    ])
    XCTAssertEqual(events.at(...300), [
      next(100, "A"),
      next(200, "B"),
      next(300, "C"),
    ])
  }
}
