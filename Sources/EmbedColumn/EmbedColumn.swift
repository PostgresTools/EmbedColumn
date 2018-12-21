//===----------------------------------------------------------------------===//
//
// @autor: Rafael Fernando Garcia Sagastume. arcangelsagastume@gmail.com
// Escuintla, Guatemala
//
// the class intends to embed the column according to the selected position
//
// Copyright © 2018 Rafael Fernando Garcia Sagastume.
//===----------------------------------------------------------------------===//

import Foundation
import FluentPostgreSQL

public class EmbedColumn {

	var conn: PostgreSQLConnection!

	public init(Conn:PostgreSQLConnection!) {
		self.conn = Conn		
	}

	public func execute(DataBase: String, SchemaName: String, TableName: String, Offset: String, Column: String, TypeColumn: String) {
		
		let _Oid = Oid(Conn: conn)
		let __Oid = _Oid.GetOid(DataBase: "dev", SchemaName: "public", TableName: "user")

		print(__Oid)


		let _keys = Keys(Conn: conn)
		print(_keys.GetUnique(DataBase: "dev", SchemaName: "public", Oid: __Oid))
		print(_keys.GetIndex(DataBase: "dev", SchemaName: "public", Oid: __Oid))
		print(_keys.GetForeign(DataBase: "dev", Oid: __Oid))
	}

}