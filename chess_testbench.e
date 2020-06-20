note
	description: "[
		Eiffel tests that can be executed by testing tool.
	]"
	author: "EiffelStudio test wizard"
	date: "$Date$"
	revision: "$Revision$"
	testing: "type/manual"

class
	CHESS_TESTBENCH

inherit
	EQA_TEST_SET

feature -- Test routines

	chess_testbench
			-- New test routine
		note
			testing:  "covers/{CHESS_BOARD}"
		local
			cb: CHESS_BOARD
		do
			create cb.default_fill
			assert ("moving nothing", false = cb.can_move([1, 5], [1, 6], true, true, true))
			assert ("not moving 1", false = cb.can_move([1, 1], [1, 1], true, true, true))
			assert ("not moving 2", false = cb.can_move([1, 2], [1, 2], true, true, true))
			assert ("moving too far", false = cb.can_move([1, 2], [1, 5], true, true, true))

			assert ("moving by pawn like capturing", false = cb.can_move([1, 2], [2, 3], true, true, true))
			assert ("can't move pawn 2 cells from start", true = cb.can_move([1, 2], [1, 4], true, true, true))
			cb.move_piece([1, 2], [1, 4])
			assert ("moving by pawn 2 cells not from start", false = cb.can_move([1, 4], [1, 6], true, true, true))
			assert ("moving by pawn backwards", false = cb.can_move([1, 4], [1, 3], true, true, true))

			assert ("moving from outside of the board", false = cb.can_move([10, 3], [1, 5], true, true, true))
			assert ("moving to outside of the board", false = cb.can_move([1, 1], [10, 3], true, true, true))
			assert ("moving through the piece", false = cb.can_move([8, 1], [8, 3], true, true, true))

			assert ("moving opponent's piece", false = cb.can_move([5, 2], [5, 3], false, true, true))
		end

end


