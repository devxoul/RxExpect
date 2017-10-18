import RxSwift
import RxTest

protocol AnyAssertion: class {
  func prepareRecorder(scheduler: TestScheduler, disposeBag: DisposeBag)
  func assert()
}

public typealias AssertionClosure<E> = ([Recorded<Event<E>>]) -> Void

open class Assertion<O: ObservableConvertibleType>: AnyAssertion {
  let source: O
  let closure: AssertionClosure<O.E>
  var recorder: TestableObserver<O.E>?

  init(source: O, closure: @escaping AssertionClosure<O.E>) {
    self.source = source
    self.closure = closure
  }

  func prepareRecorder(scheduler: TestScheduler, disposeBag: DisposeBag) {
    let recorder = scheduler.createObserver(O.E.self)
    self.recorder = recorder
    self.source.asObservable()
      .subscribe(recorder)
      .disposed(by: disposeBag)
  }

  func assert() {
    guard let recorder = self.recorder else { preconditionFailure("Call prepareRecorder() first") }
    self.closure(recorder.events)
  }
}
