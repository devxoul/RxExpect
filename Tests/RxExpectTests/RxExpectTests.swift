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

  func testAssertInfiniteObservable() {
    let test = RxExpect()
    let timer = Observable<Int>.interval(100, scheduler: test.scheduler)
    test.assert(timer, disposed: 400) { events in
      XCTAssertEqual(events, [
        next(100, 0),
        next(200, 1),
        next(300, 2),
      ])
    }
    test.assert(timer, disposed: 200) { events in
      XCTAssertEqual(events, [
        next(100, 0),
      ])
    }
  }

  func testAssertMergeOnMainScheduler() {
    let test = RxExpect()
    let subjects: [PublishSubject<String>] = [.init(), .init(), .init()]
    let obsevables = subjects.map { $0.observeOn(MainScheduler.instance) }
    let observable = Observable<String>.merge(obsevables).observeOn(MainScheduler.instance)
    test.input(subjects[0], [
      next(500, "A"),
    ])
    test.input(subjects[1], [
      next(300, "B"),
    ])
    test.input(subjects[2], [
      next(100, "C"),
      next(600, "D"),
    ])
    test.assert(observable) { events in
      XCTAssertEqual(events.elements, ["C", "B", "A", "D"])
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
