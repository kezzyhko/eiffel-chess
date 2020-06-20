note
	description: "Summary description for {ROOK}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ROOK

inherit
	PIECE

create
	make

feature
	can_move(new_position: TUPLE[x, y: INTEGER]): BOOLEAN
		do
			Result := new_position.x = position.x or new_position.y = position.y
		end
	name: STRING = "ROOK"

end
