import XCTest
@testable import EmbedColumn
import Foundation
import FluentPostgreSQL

final class EmbedColumnTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
		// XCTAssertEqual(EmbedColumn().text, "Hello, World!")
		print("version 1.0.0")
		var database: PostgreSQLDatabase!

		let config: PostgreSQLDatabaseConfig = .init(
		    hostname: "localhost",
		    port: 5432,
		    username: "rafael",
		    database: "dev",
		    password: "rafael"
		)       
		database = PostgreSQLDatabase(config: config)
		let eventLoop = MultiThreadedEventLoopGroup(numberOfThreads: 1)
		let conn1 = try! database.newConnection(on: eventLoop).wait()


		let __event = EmbedColumn(Conn: conn1)
		__event.execute(DataBase: "dev", SchemaName: "public", TableName: "user", Offset: "name", Column: "col0", TypeColumn: "INTEGER")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
