// The MIT License (MIT)
//
// Copyright (c) 2016 Suyeol Jeon (xoul.kr)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import XCTest

import RxCocoa
import RxSwift
import RxTest


// MARK: - RxExpectation

open class RxExpectation: XCTest {

  unowned let testCase: XCTestCase
  let message: String
  var assertions: [AnyAssertion] = []
  public var asserter: Asserter = Asserter(method: XCTAssert)

  open let scheduler = TestScheduler(initialClock: 0)
  open let disposeBag = DisposeBag()

  var deferredInputs: [() -> Void] = []
  var retainedObjects: [Any] = []

  var didRun: Bool = false

  public init(_ testCase: XCTestCase, message: String? = nil) {
    self.testCase = testCase
    self.message = message ?? ""
  }

  @discardableResult
  open func retain<T>(_ object: T) -> T {
    self.retainedObjects.append(object)
    return object
  }

  open func assert<O: ObservableConvertibleType>(_ source: O) -> RxAssertion<O> {
    let assertion = RxAssertion(source: source)
    self.assertions.append(assertion)
    return assertion
  }

  override open func run() {
    self.run(completion: nil)
  }

  open func run(completion: (([AssertionResult]) -> Void)? = nil) {
    guard !self.didRun else { return }
    self.didRun = true

    let disposeBag = DisposeBag()

    // prepare recorder and source
    for assertion in self.assertions {
      assertion.prepareRecorder(scheduler: self.scheduler, disposeBag: disposeBag)
    }

    // provide inputs
    self.provideInputs()

    let expectation = self.testCase.expectation(description: "")
    let lastTime = self.assertions.map { $0.maximumTime ?? 0 }.max() ?? 0
    self.scheduler.scheduleAt(lastTime + 100, action: expectation.fulfill)
    self.scheduler.start()

    self.testCase.waitForExpectations(timeout: 0.5) { error in
      self.asserter.assert(error == nil)
      let results = self.assertions.map { $0.assert(message: self.message) }
      if let completion = completion {
        completion(results)
      } else {
        for result in results {
          switch result {
          case let .success(file, line):
            self.asserter.assert(true, file: file, line: line)
          case let .failure(message, file, line):
            self.asserter.assert(false, message, file: file, line: line)
          }
        }
      }
    }
  }

}


// MARK: - Input

extension RxExpectation {

  public func input<O: ObserverType>(_ observer: O, _ events: [Recorded<Event<O.E>>], file: StaticString = #file, line: UInt = #line) {
    Swift.assert(!events.contains { $0.time == AnyTestTime }, "Input events should have specific time.", file: file, line: line)
    self.deferredInputs.append { [unowned self] in
      self.scheduler
        .createHotObservable(events)
        .bind(to: observer)
        .addDisposableTo(self.disposeBag)
    }
  }

  public func input<E>(_ variable: Variable<E>, _ events: [Recorded<Event<E>>], file: StaticString = #file, line: UInt = #line) {
    Swift.assert(!events.contains { $0.time == AnyTestTime }, "Input events should have specific time.", file: file, line: line)
    self.deferredInputs.append { [unowned self] in
      self.scheduler
        .createHotObservable(events)
        .bind(to: variable)
        .addDisposableTo(self.disposeBag)
    }
  }

  func provideInputs() {
    for deferredInput in self.deferredInputs {
      deferredInput()
    }
  }

}
