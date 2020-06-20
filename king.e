note
	description: "Summary description for {KING}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	KING

inherit
	PIECE

create
	make

feature
	can_move(new_position: TUPLE[x, y: INTEGER]): BOOLEAN
		local
			dx, dy: INTEGER
		do
			dx := (new_position.x - position.x).abs
			dy := (new_position.y - position.y).abs
			Result := (dx <= 1 and dy <= 1) or (dx = 2 and dy = 0)
		end
	name: STRING = "KING"

end
