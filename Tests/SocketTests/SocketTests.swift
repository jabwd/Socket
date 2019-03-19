import XCTest
import Dispatch
@testable import Socket

class SocketTests: XCTestCase {
    func testExample() {   
        let server = try! Server(port: 2553)
        server.newConnectionHandler = { socket in
            socket.startReading()
            return Connection(server: server, index: 0, socket: socket)
        }
        Runloop.shared.run()

        XCTAssert(true)
    }


    static var allTests = [
        ("testExample", testExample),
    ]
}
