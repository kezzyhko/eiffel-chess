note
	description: "Summary description for {QUEEN}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	QUEEN

inherit
	PIECE

create
	make

feature
	can_move(new_position: TUPLE[x, y: INTEGER]): BOOLEAN
		local
			rook: ROOK
			bishop: BISHOP
		do
			create rook.make(position, color)
			create bishop.make(position, color)
			Result := rook.can_move(new_position) or bishop.can_move(new_position)
			Result := (new_position.x = position.x or new_position.y = position.y) or ((new_position.x - position.x).abs = (new_position.y - position.y).abs)
		end
	name: STRING = "QUEEN"

end
