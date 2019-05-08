import XCTest
import RxExpect

final class AnyTestTimeTests: XCTestCase {
  func testAnyTestTime() {
    let event = AnyTestTime.next("Hey")
    XCTAssertEqual(event.value.element, "Hey")
    XCTAssertLessThan(event.time, 0)
  }
}
