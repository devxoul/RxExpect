import RxSwift
import RxTest

extension RxExpect {

  @available(*, deprecated, message: "Variable is deprecated.")
  public func input<Element>(_ variable: Variable<Element>, _ events: [Recorded<Event<Element>>], file: StaticString = #file, line: UInt = #line) {
    Swift.assert(!events.contains { $0.time == AnyTestTime }, "Input events should have specific time.", file: file, line: line)
    self.maximumInputTime = ([self.maximumInputTime] + events.map { $0.time }).max() ?? self.maximumInputTime
    self.deferredInputs.append { `self` in
      self.scheduler
        .createHotObservable(events)
        .subscribe(onNext: { variable.value = $0 })
        .disposed(by: self.disposeBag)
    }
  }
}
