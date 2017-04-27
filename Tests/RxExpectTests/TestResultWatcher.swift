//
//  TestResultWatcher.swift
//  RxExpect
//
//  Created by Suyeol Jeon on 27/04/2017.
//
//

import RxExpect

final class TestResultWatcher {
  var isPassed: Bool = false
  var message: String?
}

func watch(_ test: RxExpectation) -> TestResultWatcher {
  let result = TestResultWatcher()
  test.asserter = Asserter { [unowned result] args in
    result.isPassed = (try? args.0()) ?? false
    result.message = args.1()
  }
  return result
}
