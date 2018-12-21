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

public class Trigger {

	var conn: PostgreSQLConnection!	


	public init(Conn:PostgreSQLConnection!) {
		self.conn = Conn
	}


	public func GetTrigger(DataBase: String, Oid: Int) -> (DropIndex: String?, CreateIndex: String?) {
		var _drop_trigger: String? = nil
		var _create_trigger: String? = nil

		struct Query: Decodable {
		    var tgname: String
		    var definition: String
		    var _schema: String
		    var table_name: String
		}

		let sql_ : String = 
			"""
			SELECT t.tgname, pg_catalog.pg_get_triggerdef(t.oid, true) as definition, n.nspname as _schema, c.relname as table_name
			FROM pg_catalog.pg_trigger t
			INNER JOIN pg_catalog.pg_class c ON (c.oid = t.tgrelid)
			INNER JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
			WHERE t.tgrelid = \(Oid) AND (NOT t.tgisinternal OR (t.tgisinternal AND t.tgenabled = 'D'))
			ORDER BY 1
			"""

        let result = try! conn.raw(sql_).bind(DataBase).all(decoding: Query.self).wait()
        for row in result {
			_drop_trigger =  "DROP TRIGGER \(row.tgname) ON \(row._schema).\(row.table_name);\n"
        	_create_trigger = "\(row.definition);\n"
		}
		
		return (DropIndex: _drop_trigger, CreateIndex: _create_trigger)
	}

}