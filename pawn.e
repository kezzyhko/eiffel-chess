note
	description: "Summary description for {PAWN}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	PAWN

inherit
	PIECE

create
	make

feature {NONE}
	direction: INTEGER
		do
			Result := 2*color.to_integer-1
		end

feature
	can_move(new_position: TUPLE[x, y: INTEGER]): BOOLEAN
		local
			dx, dy: INTEGER
		do
			dx := (new_position.x - position.x).abs
			dy := (new_position.y - position.y)*direction
--			Result := (dx = 0 or dx = 1 and havaet) and (dy = 1 or dy = 2 and first_move)
			Result := dx <= 1 and (dy = 1 or dy = 2 and not already_moved)
		end
	name: STRING = "PAWN"


end
