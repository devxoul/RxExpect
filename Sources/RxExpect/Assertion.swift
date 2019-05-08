import RxSwift
import RxTest

protocol AnyAssertion: class {
  var disposeAt: TestTime? { get }

  func prepareRecorder(scheduler: TestScheduler, disposeAt: TestTime?)
  func assert()
}

public typealias AssertionClosure<E> = ([Recorded<Event<E>>]) -> Void

open class Assertion<O: ObservableConvertibleType>: AnyAssertion {
  let source: O
  let disposeAt: TestTime?
  let closure: AssertionClosure<O.Element>
  var recorder: TestableObserver<O.Element>?

  init(source: O, disposeAt: TestTime?, closure: @escaping AssertionClosure<O.Element>) {
    self.source = source
    self.disposeAt = disposeAt
    self.closure = closure
  }

  func prepareRecorder(scheduler: TestScheduler, disposeAt: TestTime?) {
    let recorder = scheduler.createObserver(O.Element.self)
    self.recorder = recorder

    let subscription = self.source.asObservable().subscribe(recorder)
    if let disposeAt = disposeAt {
      scheduler.scheduleAt(disposeAt, action: subscription.dispose)
    }
  }

  func assert() {
    guard let recorder = self.recorder else { preconditionFailure("Call prepareRecorder() first") }
    self.closure(recorder.events)
  }
}
