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
import RxSwift
import RxTest
@testable import RxExpect

class RxExpectTests: XCTestCase {

  func testSuccess() {
    XCTAssertTrue(true)
  }
  
  func testAssertArrayEquals() {
    RxExpect("it should be able to compare arrays that are the result of observables") { test in
      let value = PublishSubject<[Int]>()
      
      test.input(value, [ next(25, []), next(50, [0])])
      test.assert(value).equal([[], [0]])
    }
  }
  
  func testArrayNotEquals() {
    RxExpect("it should be able to compare to see if the resulting array from an observable is not equal to a provided value") { test in
      let value = PublishSubject<[Int]>()
      
      test.input(value, [ next(25, []), next(50, [0])])
      
      // Note: [] doesn't work; the compiler cannot infer element type without context and therefore doesn't know if it complies with Equatable
      let result: [Int] = []
      test.assert(value).notEqual([result])
    }
  }

}
