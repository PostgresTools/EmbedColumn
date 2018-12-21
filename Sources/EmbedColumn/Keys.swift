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

public class Keys {

	var conn: PostgreSQLConnection!	


	public init(Conn:PostgreSQLConnection!) {
		self.conn = Conn
	}


	//===----------------------------------------------------------------------===//
	// @autor: Rafael Fernando Garcia Sagastume. arcangelsagastume@gmail.com
	// Escuintla, Guatemala
	//
	// Extrae todos los [Unique key] que esten involucrados en la tabla
	//===----------------------------------------------------------------------===//

	public func GetUnique(DataBase: String, SchemaName: String, Oid: Int) -> (DropUnique: String?, CreateUnique: String?) {
		var _drop_unique: String? = nil
		var _create_unique: String? = nil

		struct Query: Decodable {
		    var unique: String
		    var definition: String
		    var table_name: String
		}

		let sql_ : String = 
			"""
			SELECT c2.relname as unique, pg_catalog.pg_get_indexdef(i.indexrelid, 0, true) definition, c.relname as table_name
			FROM pg_catalog.pg_class c, pg_catalog.pg_class c2, pg_catalog.pg_index i
			LEFT JOIN pg_catalog.pg_constraint con ON (conrelid = i.indrelid AND conindid = i.indexrelid AND contype = 'u')
			WHERE c.oid = \(Oid) AND c.oid = i.indrelid AND i.indexrelid = c2.oid AND i.indisprimary <> true
			ORDER BY i.indisprimary DESC, i.indisunique DESC, c2.relname
			"""

        let result = try! conn.raw(sql_).bind(DataBase).all(decoding: Query.self).wait()
        for row in result {
        	_drop_unique =  "ALTER TABLE \(SchemaName).\(row.table_name) DROP CONSTRAINT \(row.unique);\n"
        	_create_unique = "\(row.definition);\n"
		}

		return (DropUnique: _drop_unique, CreateUnique: _create_unique)
	}




	//===----------------------------------------------------------------------===//
	// @autor: Rafael Fernando Garcia Sagastume. arcangelsagastume@gmail.com
	// Escuintla, Guatemala
	//
	// Extrae todos los indices que esten involucrados en la tabla
	//===----------------------------------------------------------------------===//

	public func GetIndex(DataBase: String, SchemaName: String, Oid: Int) -> (DropIndex: String?, CreateIndex: String?) {
		var _drop_index: String? = nil
		var _create_index: String? = nil

		struct Query: Decodable {
		    var index: String
		    var definition: String
		    var table_name: String
		}

		let sql_ : String = 
			"""
			SELECT c2.relname as index, pg_catalog.pg_get_indexdef(i.indexrelid, 0, true) definition, c.relname as table_name
			FROM pg_catalog.pg_class c, pg_catalog.pg_class c2, pg_catalog.pg_index i
			LEFT JOIN pg_catalog.pg_constraint con ON (conrelid = i.indrelid AND conindid = i.indexrelid AND contype = 'x')
			WHERE c.oid = \(Oid) AND c.oid = i.indrelid AND i.indexrelid = c2.oid AND i.indisprimary <> true
			ORDER BY i.indisprimary DESC, i.indisunique DESC, c2.relname
			"""

        let result = try! conn.raw(sql_).bind(DataBase).all(decoding: Query.self).wait()
        for row in result {
        	_drop_index =  "DROP INDEX \(SchemaName).\(row.table_name) \(row.index);\n"
        	_create_index = "\(row.definition);\n"
		}

		return (DropIndex: _drop_index, CreateIndex: _create_index)
	}



	//===----------------------------------------------------------------------===//
	// @autor: Rafael Fernando Garcia Sagastume. arcangelsagastume@gmail.com
	// Escuintla, Guatemala
	//
	// Extrae todos las llaves foraneas involucradas en la tabla
	//===----------------------------------------------------------------------===//

	public func GetForeign(DataBase: String, Oid: Int) -> (DropIndex: String?, CreateIndex: String?) {
		var _drop_foreign: String? = nil
		var _create_foreign: String? = nil

		struct Query: Decodable {
		    var conname: String
		    var definition: String
		    var _schema: String
		    var table_name: String
		}

		let sql_ : String = 
			"""
			SELECT conname,
			pg_catalog.pg_get_constraintdef(r.oid, true) as definition, n.nspname as _schema, c.relname as table_name
			FROM pg_catalog.pg_constraint r
			INNER JOIN pg_catalog.pg_class c ON (c.oid = r.conrelid)
			INNER JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
			WHERE r.conrelid = \(Oid) AND r.contype = 'f' ORDER BY 1
			"""

        let result = try! conn.raw(sql_).bind(DataBase).all(decoding: Query.self).wait()
        for row in result {
        	_drop_foreign =  "ALTER TABLE \(row._schema).\(row.table_name) DROP CONSTRAINT \(row.conname);\n"
        	_create_foreign = "ALTER TABLE \(row._schema).\(row.table_name) ADD CONSTRAINT \(row.conname) \(row.definition);\n"
		}

		return (DropIndex: _drop_foreign, CreateIndex: _create_foreign)
	}

}