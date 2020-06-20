note
	description: "Summary description for {CHESS_BOARD}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

--TODO: vzyatie na prohode
class
	CHESS_BOARD

inherit
	EXECUTION_ENVIRONMENT

create
	default_fill, make

feature {NONE} --constructors
	default_fill
		local
			color: BOOLEAN
		do
			create chess_board.make_filled(Void, 8, 8)
			across 1 |..| 8 as x loop
				across <<false, true>> as bool loop color := bool.item
					add_piece([x.item, mux(7, 2, color.to_integer)], 0, color)
					add_piece([x.item, mux(8, 1, color.to_integer)], x.item, color)
				end
				across 3 |..| 6 as y loop
					add_piece([x.item, y.item], -1, color)
				end
			end
		end
	castling_test_fill
		do
			create chess_board.make_filled(Void, 8, 8)
			add_piece([1,1], 1, true)
			add_piece([5,1], 5, true)
			add_piece([8,1], 1, true)
			add_piece([6,8], 1, false)
			add_piece([2,8], 5, false)
		end
	make
		local
			current_player, check_reported: BOOLEAN
			i: INTEGER
			s: STRING
			p: ARRAY[INTEGER]
			p1, p2: detachable TUPLE[x, y: INTEGER]
		do
			default_fill
			--castling_test_fill

			from
				current_player := true --white first
			until
				is_check_mate(current_player)
			loop
				if is_check(current_player) and not check_reported then
					change_message("It's check for " + color_string(current_player) + ", press Return to continue")
					check_reported := true
				end
				change_message("It's the turn of " + color_string(current_player))
				s := Io.last_string.as_lower

				if s~"0-0" or s~"0-0-0" then
					--castling
					if king(current_player).already_moved then
						change_message("Castling can't be done: king aready moved")
					else
						p1 := king(current_player).position
						p2 := [p1.x + (4-s.count)*2, p1.y]
					end
				elseif s.count/=5 or not s[1].is_alpha or not s[2].is_digit or s[3]/='-' or not s[4].is_alpha or not s[5].is_digit then
					change_message("Wrong format, press Return to continue")
					p1 := Void
					p2 := Void
				else
					--input to coords
					create p.make_filled(0, 1, 5)
					across 0 |..| 1 as from_to loop
						across 0 |..| 1 as letter_number loop
							i := mux(4, 1, from_to.item) + letter_number.item
							p[i] := s[i].code - mux(('a').code, ('1').code, letter_number.item) + 1
						end
					end
					p1 := [p[1], p[2]]
					p2 := [p[4], p[5]]
				end
				if attached p1 as p_from and attached p2 as p_to then
					if can_move(p_from, p_to, current_player, true, true) then
						move_piece(p_from, p_to)
						current_player := not current_player
						check_reported := false
					end
				end
			end
			change_message(color_string(not current_player) + " won, press Return to exit")
		end

feature {NONE} --pieces operations
	chess_board: ARRAY2[detachable PIECE]
	on_board(pos: TUPLE[x, y: INTEGER]): BOOLEAN
		do
			Result := (1<=pos.x and pos.x<=8) and (1<=pos.y and pos.y<=8)
		ensure
			class
		end
	add_piece(pos: TUPLE[x, y: INTEGER]; type: INTEGER; color: BOOLEAN)
		require
			type_in_bounds: -1<=type and type<=8
		local
			p: detachable PIECE
		do
			inspect type
				when 0 then
					create {PAWN}p.make(pos, color)
				when 1,8 then
					create {ROOK}p.make(pos, color)
				when 2,7 then
					create {KNIGHT}p.make(pos, color)
				when 3,6 then
					create {BISHOP}p.make(pos, color)
				when 4 then
					create {QUEEN}p.make(pos, color)
				when 5 then
					create {KING}p.make(pos, color)
				else
					p:=Void
			end
			chess_board.force(p, pos.x, pos.y)
		end
	king(color: BOOLEAN): KING
		do
			create Result.make([1,1],color) --I HATE VOID SAFETY
			across chess_board as piece loop
				if attached {KING}piece.item as k then
					if k.color = color then
						Result := k
					end
				end
			end
		end
	no_pieces_between(p1, p2: TUPLE[x, y: INTEGER]): BOOLEAN
		local
			x, y, dx, dy: INTEGER
		do
			Result := true
			dx := (p2.x - p1.x)
			if dx /= 0 then
				dx := (dx/dx.abs).ceiling
			end
			dy := (p2.y - p1.y)
			if dy /= 0 then
				dy := (dy/dy.abs).ceiling
			end
			if dx /= 0 or dy /= 0 then
				from
					x := p1.x+dx
					y := p1.y+dy
				until
					dx /= 0 and dx*x > (p2.x-dx)*dx
					or
					dy /= 0 and dy*y > (p2.y-dy)*dy
				loop
					if attached chess_board[x, y] then
						Result := false
					end
					x := x + dx
					y := y + dy
				end
			end
		end
	check_after_move(p1, p2: TUPLE[x, y: INTEGER]): BOOLEAN
		local
			board_backup: ARRAY2[detachable PIECE]
			piece_backup: PIECE
		do
			if attached chess_board[p1.x, p1.y] as piece then
				board_backup := chess_board.twin
				piece_backup := piece.twin

				piece.move(p2)
				chess_board[p2.x, p2.y] := piece
				chess_board[p1.x, p1.y] := Void

				Result := is_check(piece.color)
				chess_board := board_backup.twin
				chess_board[p1.x, p1.y] := piece_backup.twin
			end
		end
	castling_rook(p1, p2: TUPLE[x, y: INTEGER]): TUPLE[old_x, new_x: INTEGER]
		local
			control: INTEGER
		do
			Result := [0,0]
			control := ((p2.x - p1.x).to_real.three_way_comparison(0.5)+1)//2
			Result.old_x := p1.x+mux(-4, 3, control)
			Result.new_x := p1.x+mux(-1, 1, control)
		end

feature --pieces operations
	can_move(p1, p2: TUPLE[x, y: INTEGER]; color, king_safety, output: BOOLEAN): BOOLEAN
		local
			p2_is_opposite, p2_is_empty: BOOLEAN
			error: STRING
			rook_x: INTEGER
		do
			error := ""
			if not on_board(p1) or not on_board(p2) then
				error := "Coords are outside of the board"
			elseif attached chess_board[p1.x, p1.y] as piece then
				if error~"" and not piece.color = color then
					error := "You can't move your opponent's pieces"
				end

				if error~"" and not piece.can_move(p2) then
					error := "Wrong move for this type of figure"
				end

				if p1 ~ p2 then
					error := "No, you can't stay, you need to move"
				end

				p2_is_empty := not attached chess_board[p2.x, p2.y]
				if attached chess_board[p2.x, p2.y] as destination then
					p2_is_opposite := destination.color = not piece.color
				else
					p2_is_opposite := false
				end
				if attached {PAWN}piece then
					if (p2.x - p1.x).abs = 0 then
						if error~"" and not p2_is_empty then
							error := "Wrong move for this type of figure"
						end
					else
						if error~"" and not p2_is_opposite then
							error := "Wrong move for this type of figure"
						end
					end
				else
					if error~"" and not p2_is_opposite and not p2_is_empty then
						error := "You can't capture piece of your color"
					end
				end

				if error~"" and not attached {KNIGHT}piece and not no_pieces_between(p1, p2) then
					error := "You can't move through a piece(s) unless you are a knight"
				end

				if error~"" and attached {KING}piece and (p2.x-p1.x).abs=2 and p2.y=p1.y then
					rook_x := p1.x+mux(-4, 3, ((p2.x - p1.x).to_real.three_way_comparison(0.5)+1)//2)
					if not on_board([rook_x, p2.y]) then
						error.append(", too small board")
					elseif attached chess_board[rook_x, p2.y] as rook then
						if rook.already_moved then
							error.append(", rook already moved")
						else
							if error~"" and not no_pieces_between(king(color).position, rook.position) then
								error.append(", there are figure between rook and king")
							end
							if error~"" and is_check(color) then
								error.append(", it's check")
							end
							if error~"" and check_after_move(king(color).position, [castling_rook(p1, p2).new_x, p2.y]) then
								error.append(", it would be check on the way")
							end
						end
					else
						error.append(", rook not found")
					end
					if error/~"" then
						error := "Castling can't be done:" + error.substring(2, error.count)
					end
				end

				if error~"" and king_safety and check_after_move(p1, p2) then
					error := "This will kill your king, so you can't do this"
				end
			else
				error := "No piece at this coords"
			end

			Result := error~""
			if output and error/~"" then
				change_message(error + ", press Return to continue")
			end
		end
	move_piece(p1, p2: TUPLE[x, y: INTEGER])
		require
			can_move: can_move(p1, p2, true, true, false) or can_move(p1, p2, false, true, false)
		local
			old_x, new_x: integer
			correct_piece_name: BOOLEAN
			s: STRING
			type: INTEGER
		do
			if attached chess_board[p1.x, p1.y] as piece then
				piece.move(p2)
				chess_board[p2.x, p2.y] := piece
				chess_board[p1.x, p1.y] := Void
				if attached {KING}piece and (p2.x-p1.x).abs=2 then
					old_x := castling_rook(p1, p2).old_x
					new_x := castling_rook(p1, p2).new_x
					if attached chess_board[old_x, p2.y] as rook then
						rook.move([new_x, p2.y])
						chess_board[new_x, p2.y] := rook
						chess_board[old_x, p2.y] := Void
					end
				end
				if attached {PAWN}piece and piece.position.y = mux(1, 8, piece.color.to_integer) then
					from until correct_piece_name loop
						change_message("What do you want do place instead of pawn (rook/knight/bisop/queen)?")
						s := Io.last_string.as_upper

						correct_piece_name := true
						if (s ~ "ROOK") then
							type := 1
						elseif (s ~ "KNIGHT") then
							type := 2
						elseif (s ~ "BISHOP") then
							type := 3
						elseif (s ~ "QUEEN") then
							type := 4
						else
							correct_piece_name := false
						end
					end
					add_piece(p2, type, piece.color)
				end
			end
		ensure
			moved: attached chess_board[p2.x, p2.y] and not attached chess_board[p1.x, p1.y]
			in_sync: attached chess_board[p2.x, p2.y] as piece implies piece.position ~ p2
		end
	is_check(color: BOOLEAN): BOOLEAN
		do
			Result := false
			across chess_board as p loop
				if attached p.item as piece then
					if can_move(piece.position, king(color).position, not color, false, false) then
						Result := true
					end
				end
			end
		end
	is_check_mate(color: BOOLEAN): BOOLEAN
		local
			kx, ky: INTEGER
			k: KING
		do
			k := king(color)
			kx := k.position.x
			ky := k.position.y
			Result := is_check(color)
			across (ky-1) |..| (ky+1) as y loop
				across (kx-1) |..| (kx+1) as x loop
					if can_move([kx, ky], [x.item, y.item], color, true, false) then
						Result := false
					end
				end
			end
		end
feature {NONE} --output things
	cell_width: INTEGER = 9
	cell_height: INTEGER
		do
			Result := cell_width//2
		end

	print_board
		local
			hr, str: STRING
			x, y, mid: INTEGER
		do
			hr := line("+"+line("-", cell_width), 8)+"+%N"
			mid := cell_height//2

			print(hr)
			across 1 |..| 8 as i loop y := 9-i.item
				across 1 |..| cell_height as l loop
					across 1 |..| 8 as j loop x := j.item
						str := ""
						if attached chess_board[x, y] as piece then
							if l.item = mid then
								str := color_string(piece.color)
							elseif l.item = mid+1 then
								str := piece.name
							end
						end
						print("|" + pad(str, mux(('.').code, (' ').code, (x+y)\\2).to_character, cell_width))
					end
					print("|%N")
				end
				print(hr)
			end
		end
	change_message(msg: STRING)
		require
			empty_message: msg /~ ""
		do
			system("cls")
			print_board
			print(msg + "%N")
			Io.read_line
		end
	color_string(color: BOOLEAN): STRING
		do
			if color then
				Result := "WHITE"
			else
				Result := "BLACK"
			end
		end

feature {NONE} --helpers
	mux(on_zero, on_one: INTEGER; control: INTEGER): INTEGER
		require
			control_is_one_bit: control = 0 or control = 1
		do
			Result := (1-control)*on_zero + on_one*control
		ensure
			control = 0 implies Result = on_zero
			control = 1 implies Result = on_one
		end
	line (l: STRING; n: INTEGER): STRING
		require
			meaningful: n >= 0
		do
			Result := l
			if n = 0 then
				Result := ""
			else
				Result.multiply(n)
			end
		end
	pad(l: STRING; c: CHARACTER; n: INTEGER): STRING
		require
			l_is_small_enough: l.count <= n
		local
			to_add: INTEGER
		do
			to_add := n-l.count
			Result := line(c.out, to_add//2) + l + line(c.out, to_add//2 + to_add\\2)
		end

invariant
	cell_big_enough: cell_width >= 6 and cell_height >= 2
	in_sync:	across chess_board as p all
					attached p.item as piece implies
						(chess_board.occurrences(piece)=1 and chess_board[piece.position.x, piece.position.y]=piece)
				end

end
