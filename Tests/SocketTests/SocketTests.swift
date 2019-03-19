import XCTest
import Dispatch
@testable import Socket

class SocketTests: XCTestCase {
    func testExample() {   
        let server = try? Server(port: 2553)
        
        Runloop.shared.run()

        XCTAssert(true)
    }


    static var allTests = [
        ("testExample", testExample),
    ]
}
