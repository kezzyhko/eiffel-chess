note
	description: "Summary description for {BISHOP}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	BISHOP

inherit
	PIECE

create
	make

feature
	can_move(new_position: TUPLE[x, y: INTEGER]): BOOLEAN
		do
			Result := (new_position.x - position.x).abs = (new_position.y - position.y).abs
		end
	name: STRING = "BISHOP"

end
