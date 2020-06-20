note
	description: "Summary description for {PIECE}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

deferred
class
	PIECE

feature {NONE}
	make(pos: TUPLE[x, y: INTEGER]; is_white: BOOLEAN)
		do
			position := pos
			color := is_white
		end

feature {CHESS_BOARD}
	move(new_position: TUPLE[x, y: INTEGER])
		require
			can_move: can_move(new_position)
		do
			position := new_position
			already_moved := true
		end
	already_moved: BOOLEAN

feature
	position: TUPLE[x, y: INTEGER]
	can_move(new_position: TUPLE[x, y: INTEGER]): BOOLEAN
		deferred
		end
	name: STRING
		deferred
		end

	color: BOOLEAN
end
