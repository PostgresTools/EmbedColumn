//===----------------------------------------------------------------------===//
//
// @autor: Rafael Fernando Garcia Sagastume. arcangelsagastume@gmail.com
// Escuintla, Guatemala
//
// This class will contain as much as possible of sql utility or postgresql queries
//
// Copyright © 2018 Rafael Fernando Garcia Sagastume.
//===----------------------------------------------------------------------===//

import Foundation
import FluentPostgreSQL

public class Oid {

	var conn: PostgreSQLConnection!	


	public init(Conn:PostgreSQLConnection!) {
		self.conn = Conn
	}


	public func GetOid(DataBase: String, SchemaName: String, TableName: String) -> Int {
		var oid: Int? = nil

		struct Query: Decodable {
		    var oid: Int
		}

		let sql_ : String = 
			"""
			SELECT c.oid::integer as oid
			FROM pg_catalog.pg_class c
			LEFT JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
			WHERE n.nspname OPERATOR(pg_catalog.~) ('^(\(SchemaName))$') 
			AND (c.relname OPERATOR(pg_catalog.~) ('^(\(TableName))$')) LIMIT 1;
			"""

        let result = try! conn.raw(sql_).bind(DataBase).all(decoding: Query.self).wait()
        for row in result {
			oid = row.oid
		}
		
		return oid!
	}

}