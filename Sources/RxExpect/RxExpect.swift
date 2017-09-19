import XCTest
import RxSwift
import RxTest

open class RxExpect {
  open let scheduler = TestScheduler(initialClock: 0)
  open let disposeBag = DisposeBag()

  let file: StaticString
  let line: UInt

  var retainedObjects: [AnyObject] = []
  var deferredInputs: [(RxExpect) -> Void] = []
  var assertions: [AnyAssertion] = []
  var maximumTime: TestTime = 0

  public init(file: StaticString = #file, line: UInt = #line) {
    self.file = file
    self.line = line
  }

  deinit {
    self.run()
  }

  @discardableResult
  public func retain<T: AnyObject>(_ object: T) -> T {
    self.retainedObjects.append(object)
    return object
  }

  public func input<O: ObserverType>(_ observer: O, _ events: [Recorded<Event<O.E>>], file: StaticString = #file, line: UInt = #line) {
    Swift.assert(!events.contains { $0.time == AnyTestTime }, "Input events should have specific time.", file: file, line: line)
    self.maximumTime = ([self.maximumTime] + events.map { $0.time }).max() ?? self.maximumTime
    self.deferredInputs.append { `self` in
      self.scheduler
        .createHotObservable(events)
        .subscribe(observer)
        .disposed(by: self.disposeBag)
    }
  }

  public func input<E>(_ variable: Variable<E>, _ events: [Recorded<Event<E>>], file: StaticString = #file, line: UInt = #line) {
    Swift.assert(!events.contains { $0.time == AnyTestTime }, "Input events should have specific time.", file: file, line: line)
    self.maximumTime = ([self.maximumTime] + events.map { $0.time }).max() ?? self.maximumTime
    self.deferredInputs.append { `self` in
      self.scheduler
        .createHotObservable(events)
        .subscribe(onNext: { variable.value = $0 })
        .disposed(by: self.disposeBag)
    }
  }

  open func assert<O: ObservableConvertibleType>(_ source: O, closure: @escaping AssertionClosure<O.E>) {
    let assertion = Assertion(source: source, closure: closure)
    self.assertions.append(assertion)
  }

  private func run() {
    let disposeBag = DisposeBag()
    let expectation = XCTestExpectation()

    // prepare recorder and source
    for assertion in self.assertions {
      assertion.prepareRecorder(scheduler: self.scheduler, disposeBag: disposeBag)
    }

    // provide inputs
    for deferredInput in self.deferredInputs {
      deferredInput(self)
    }

    // start scheduler
    self.scheduler.scheduleAt(self.maximumTime, action: expectation.fulfill)
    self.scheduler.start()

    XCTWaiter().wait(for: [expectation], timeout: 5)

    // assert
    for assertion in self.assertions {
      assertion.assert()
    }
  }
}
