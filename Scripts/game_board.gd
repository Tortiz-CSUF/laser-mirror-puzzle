extends Node2D

# vars
var grid_width: int = 8
var grid_height: int = 8
var grid: Array = [] 			# Pieces data

var action_count: int = 0
var action_history: Array = []
var dragging_cell: Vector2i = Vector2i(-1, -1)
var drag_axis: String = ""

# UI
var level_active: bool = true

# Innventory System
var inventory: Array = []
var selected_inventory_index: int = -1


## Player Input
func _input(event: InputEvent):
	if not level_active:
		return
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			var cell := _world_to_grid(event.position)
			if not _is_valid_cell(cell):
				return
			var data: Dictionary = grid[cell.x][cell.y]
			var type: int = data["type"]
		
			# Rotate mirrors that are rotateable
			if type in [GameData.PieceType.MIRROR_ROTATE_SINGLE, GameData.PieceType.MIRROR_ROTATE_DOUBLE]:
				var old_dir: int = data["mirror_dir"]
				_rotate_mirror(cell)
				_record_action({"action": "rotate", "cell": cell, "old_dir": old_dir, "new_dir": data["mirror_dir"]})
				
			# Start sliding
			elif type in [GameData.PieceType.MIRROR_SLIDE_H, GameData.PieceType.MIRROR_SLIDE_V]:
				dragging_cell = cell
				drag_axis = data["slide_axis"]
				
				# place fro inventory to tiles	
			elif type == GameData.PieceType.EMPTY and selected_inventory_index >= 0:
				if not _is_hazard_cell(cell):
					_place_from_inventory(cell)
				
		else:
			# Mouse Release to finish slide
			if dragging_cell != Vector2i(-1, -1):
				dragging_cell = Vector2i(-1, -1)
				drag_axis = ""
				
	elif event is InputEventMouseMotion and dragging_cell != Vector2i(-1, -1):
		_handle_slide(event.position)
	

					

func _rotate_mirror(cell: Vector2i):
	var data: Dictionary = grid[cell.x][cell.y]
	
	#cylce directions NE, NW, SW, SE, NE
	match data["mirror_dir"]:
		GameData.MirrorDir.NE: data["mirror_dir"] = GameData.MirrorDir.NW
		GameData.MirrorDir.NW: data["mirror_dir"] = GameData.MirrorDir.SW
		GameData.MirrorDir.SW: data["mirror_dir"] = GameData.MirrorDir.SE
		GameData.MirrorDir.SE: data["mirror_dir"] = GameData.MirrorDir.NE
	
	_cast_all_lasers()
	

func _ready() -> void:
	$TileBackground.z_index = -1
	$LaserBeams.z_index = -1
	_init_grid()
	_place_test_pieces()
	_draw_tiles()
	_cast_all_lasers()
	
	$UI/UndoButton.pressed.connect(undo_action)
	$UI/ResetButton.pressed.connect(reset_level)
	$UI/FailPanel/RetryButton.pressed.connect(_on_retry)
	$UI/WinPanel/MenuButton.pressed.connect(_on_menu)

func _empty_cell() -> Dictionary:
	return{
		"type": GameData.PieceType.EMPTY,
		"mirror_dir": GameData.MirrorDir.NE,
		"double_sided": false,
		"rootable": false,
		"slide_axis": "",
		"slide_min": 0,
		"slide_max": 0,
		"laser_dir": GameData.Dir.RIGHT,
		"color_index": 0,
		"hit": false,
		
	}


func _init_grid():
	grid = []
	for x in range(grid_width):
		var col := []
		for y in range(grid_height):
			col.append(_empty_cell())
		grid.append(col)


func _place_test_pieces():
	# Laser at (0,3) shooting right
	grid[0][3]["type"] = GameData.PieceType.LASER
	grid[0][3]["laser_dir"] = GameData.Dir.RIGHT
	grid[0][3]["color_index"] = 0
	
	# Rotatable mirror at (4,3)
	grid[4][3]["type"] = GameData.PieceType.MIRROR_ROTATE_DOUBLE
	grid[4][3]["mirror_dir"] = GameData.MirrorDir.NE
	grid[4][3]["double_sided"] = true
	
	# Horizontal Slider at (4,6) can slide col 2-6
	grid[4][6]["type"] = GameData.PieceType.MIRROR_SLIDE_H
	grid[4][6]["mirror_dir"] = GameData.MirrorDir.NW
	grid[4][6]["double_sided"] = true
	grid[4][6]["slide_axis"] = "h"
	grid[4][6]["slide_min"] = 2
	grid[4][6]["slide_max"] = 6
	
	# Goal at (2,1)
	grid[2][1]["type"] = GameData.PieceType.GOAL
	grid[2][1]["color_index"] = 0
	
	# Bomb at (4,7)
	grid[4][7]["type"] = GameData.PieceType.BOMB


func _draw_tiles():
	var tile_bg := $TileBackground
	# clear old tiles
	for child in tile_bg.get_children():
		child.queue_free()
		
	for x in range(grid_width):
		for y in range(grid_height):
			var tile := ColorRect.new()
			tile.size = Vector2(GameData.CELL_SIZE - 2, GameData.CELL_SIZE - 2)
			tile.position = _grid_to_world(Vector2i(x, y)) + Vector2(1, 1)
			tile.color = GameData.COLOR_TILE_EMPTY
			tile_bg.add_child(tile)
			
	# Draw grid border
	queue_redraw()
	
	
func _grid_to_world(cell: Vector2i) -> Vector2:
	return GameData.GRID_OFFSET + Vector2(cell.x * GameData.CELL_SIZE, cell.y * GameData.CELL_SIZE)
	
	
func _cell_center(cell : Vector2i) -> Vector2:
	return _grid_to_world(cell) + Vector2(GameData.CELL_SIZE / 2.0, GameData.CELL_SIZE / 2.0)
	
	
func _world_to_grid(world_pos: Vector2) -> Vector2i:
	var local := world_pos - GameData.GRID_OFFSET
	var gx := int(local.x / GameData.CELL_SIZE)
	var gy := int(local.y / GameData.CELL_SIZE)
	return Vector2i(gx, gy)
	
	
func _is_valid_cell(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.x < grid_width and cell.y >= 0 and cell.y < grid_height
	

## HELPERS
func _next_cell(cell: Vector2i, dir: int) -> Vector2i:
	match dir:
		GameData.Dir.UP: return cell + Vector2i(0, -1)
		GameData.Dir.DOWN: return cell + Vector2i(0, 1)
		GameData.Dir.LEFT: return cell + Vector2i(-1, 0)
		GameData.Dir.RIGHT: return cell + Vector2i(1, 0)
	return cell
	

func _edge_point(cell: Vector2i, dir: int) -> Vector2:
	var center := _cell_center(cell)
	var half := GameData.CELL_SIZE / 2.0
	match dir:
		GameData.Dir.UP: return center + Vector2(0, -half)
		GameData.Dir.DOWN: return center + Vector2(0, half)
		GameData.Dir.LEFT: return center + Vector2(-half, 0)
		GameData.Dir.RIGHT: return center + Vector2(half, 0)
	return center


func _is_mirror(type: int) -> bool:
	return type in [
		GameData.PieceType.MIRROR_STATIC_SINGLE,
		GameData.PieceType.MIRROR_STATIC_DOUBLE,
		GameData.PieceType.MIRROR_ROTATE_SINGLE,
		GameData.PieceType.MIRROR_ROTATE_DOUBLE,
		GameData.PieceType.MIRROR_SLIDE_H,
		GameData.PieceType.MIRROR_SLIDE_V,
		
	]


func _draw():
	# Draw border
	var rect := Rect2(GameData.GRID_OFFSET, Vector2(grid_width * GameData.CELL_SIZE, grid_height * GameData.CELL_SIZE))
	draw_rect(rect, GameData.COLOR_GRID_LINE, false, 2.0)
	
	# draw grid lines
	for x in range(1, grid_width):
		var from := GameData.GRID_OFFSET + Vector2(x * GameData.CELL_SIZE, 0)
		var to := from + Vector2(0, grid_height * GameData.CELL_SIZE)
		draw_line(from, to, GameData.COLOR_GRID_LINE, 1.0)
		
	for y in range(1, grid_height):
		var from := GameData.GRID_OFFSET + Vector2(0, y * GameData.CELL_SIZE)
		var to := from + Vector2(grid_width * GameData.CELL_SIZE, 0)
		draw_line(from, to, GameData.COLOR_GRID_LINE, 1.0)
		
	# draws all pieces
	for x in range(grid_width):
		for y in range(grid_height):
			_draw_piece(Vector2i(x, y))
	

func _draw_piece(cell: Vector2i):
	var data : Dictionary = grid[cell.x][cell.y]
	var type: int = data["type"]
	var center := _cell_center(cell)
	var half := GameData.CELL_SIZE / 2.0
	var quarter := GameData.CELL_SIZE / 4.0
	
	if type == GameData.PieceType.EMPTY:
		return
		
	elif type == GameData.PieceType.LASER:
		var r := Rect2(center - Vector2(quarter, quarter), Vector2(quarter * 2, quarter * 2))
		draw_rect(r, GameData.COLOR_LASER_SOURCE)
		var arrow_end := center
		match data["laser_dir"]:
			GameData.Dir.RIGHT: arrow_end += Vector2(quarter, 0)
			GameData.Dir.LEFT: arrow_end -= Vector2(quarter, 0)
			GameData.Dir.DOWN: arrow_end += Vector2(0, quarter)
			GameData.Dir.UP: arrow_end -= Vector2(0, quarter)
		draw_line(center, arrow_end, Color.WHITE, 2.0)
		
	elif type == GameData.PieceType.GOAL:
		var color: Color = GameData.COLOR_GOAL_ACTIVE if data["hit"] else GameData.COLOR_GOAL_INACTIVE
		draw_circle(center, quarter, color)
		
	elif _is_mirror(type):
		_draw_mirror(center, data)
		
	elif type == GameData.PieceType.BARRIER:
		var r := Rect2(center - Vector2(half - 4, half - 4), Vector2((half - 4) * 2, (half - 4) * 2 ))
		draw_rect(r, GameData.COLOR_BARRIER)
		
	elif type == GameData.PieceType.HAZARD:
		var r:= Rect2(center - Vector2(half - 4, half - 4), Vector2((half - 4) * 2, (half - 4) * 2))
		draw_rect(r, GameData.COLOR_HAZARD)
		
	elif type == GameData.PieceType.BOMB:
		var tex := preload("res://Assets/Cartoon Bomb.png")
		var scale_factor: float = (GameData.CELL_SIZE - 8.0) / float(max(tex.get_width(), tex.get_height()))
		var tex_size := Vector2(tex.get_width(), tex.get_height()) * scale_factor
		draw_texture_rect(tex, Rect2(center - tex_size / 2.0, tex_size), false)
	
	
func _draw_mirror(center: Vector2, data: Dictionary):
	var offset := GameData.CELL_SIZE / 2.0 - 6.0
	var mdir : int = data["mirror_dir"]
	var is_backslash: bool = (mdir == GameData.MirrorDir.NE or mdir == GameData.MirrorDir.SW)
	var from: Vector2
	var to: Vector2
	
	if is_backslash:
		from = center + Vector2(-offset, -offset)
		to = center + Vector2(offset, offset)
	else:
		from = center + Vector2(offset, -offset)
		to = center + Vector2(-offset, offset)
	
	# reflective side
	draw_line(from, to, GameData.COLOR_MIRROR, 4.0)
	
	# single sides
	if not data["double_sided"]:
		var back_offset := 3.0
		var normal: Vector2
		if is_backslash:
			if mdir == GameData.MirrorDir.NE:
				normal = Vector2(1, -1).normalized() * back_offset
			else:
				normal = Vector2(-1, 1).normalized() * back_offset
		else:
			if mdir == GameData.MirrorDir.NW:
				normal = Vector2(-1, -1).normalized() * back_offset
			else:
				normal = Vector2(1, 1).normalized() * back_offset
		draw_line(from + normal, to + normal, GameData.COLOR_BARRIER, 2.0)
	
	
## Laser System
func _cast_all_lasers():
	var beam_parent := $LaserBeams
	for child in beam_parent.get_children():
		child.queue_free()
		
	# reset all hits
	for x in range(grid_width):
		for y in range(grid_height):
			grid[x][y]["hit"] = false
			
	# cast from every laser source
	for x in range(grid_width):
		for y in range(grid_height):
			if grid [x][y]["type"] == GameData.PieceType.LASER:
				_cast_laser(Vector2i(x, y), grid[x][y]["laser_dir"], grid[x][y]["color_index"])
				
	queue_redraw()
	_check_win_loss()
	
	
	
func _check_win_loss():
	if not level_active:
		return
		
	# check for bomb hit
	for x in range(grid_width):
		for y in range(grid_height):
			if grid[x][y]["type"] == GameData.PieceType.BOMB and grid[x][y]["hit"]:
				_trigger_fail()		
				return
				
	# check if all goals hit
	var all_goals_hit := true
	for x in range(grid_width):
		for y in range(grid_height):
			if grid[x][y]["type"] == GameData.PieceType.GOAL:
				if not grid[x][y]["hit"]:
					all_goals_hit = false
					break
		if not all_goals_hit:
			break
			
	if all_goals_hit:
		_trigger_win()			
		

func _trigger_win():
	level_active = false
	$UI/WinPanel.visible = true
	$UI/WinPanel/WinLabel.text = "Level Complete!\nActions: " + str(action_count)

func _trigger_fail():
	level_active = false
	$UI/FailPanel.visible = true


func _cast_laser(start: Vector2i, dir: int, color_idx: int):
	var beam_points: PackedVector2Array = []
	beam_points.append(_cell_center(start))
	
	var current := start
	var current_dir := dir
	var max_steps := (grid_width + grid_height) * 4
	var steps:= 0
	
	while steps < max_steps:
		steps += 1
		var next := _next_cell(current, current_dir)
		
		if not _is_valid_cell(next):
			beam_points.append(_edge_point(current, current_dir))
			break
			
		var cell_data: Dictionary = grid[next.x][next.y]
		var cell_type: int = cell_data["type"]
		
		if cell_type == GameData.PieceType.EMPTY or cell_type == GameData.PieceType.HAZARD:
			beam_points.append(_cell_center(next))
			current = next
			
		elif cell_type == GameData.PieceType.GOAL:
			beam_points.append(_cell_center(next))
			if cell_data["color_index"] == color_idx:
				cell_data["hit"] = true
			break
			
		elif cell_type == GameData.PieceType.BARRIER or cell_type == GameData.PieceType.LASER:
			beam_points.append(_edge_point(current, current_dir))
			break
			
		elif  cell_type == GameData.PieceType.BOMB:
			beam_points.append(_cell_center(next))
			cell_data["hit"] = true
			break
		elif _is_mirror(cell_type):
			var reflect_result := _reflect(current_dir, cell_data)
			if reflect_result == -1:
				beam_points.append(_edge_point(current, current_dir))
				break
			else:
				beam_points.append(_cell_center(next))
				current = next
				current_dir = reflect_result	
				
	_create_beam_line(beam_points)
	
	
func _reflect(incoming_dir: int, cell_data: Dictionary) -> int:
	var mdir: int = cell_data["mirror_dir"]
	var double: bool = cell_data["double_sided"]
	var is_backslash: bool = (mdir == GameData.MirrorDir.NE or mdir == GameData.MirrorDir.SW)
	
	if not double:
		if not _hits_reflective_face(incoming_dir, mdir):
			return -1
	
	if is_backslash:
		match incoming_dir:
			GameData.Dir.RIGHT: return GameData.Dir.DOWN
			GameData.Dir.DOWN: return GameData.Dir.RIGHT
			GameData.Dir.LEFT: return GameData.Dir.UP
			GameData.Dir.UP: return GameData.Dir.LEFT
	else:
		match incoming_dir:
			GameData.Dir.RIGHT: return GameData.Dir.UP
			GameData.Dir.UP: return GameData.Dir.RIGHT
			GameData.Dir.LEFT: return GameData.Dir.DOWN
			GameData.Dir.DOWN: return GameData.Dir.LEFT
	return -1
	
	
func _hits_reflective_face(incoming_dir: int, mdir: int) -> bool:
	match mdir:
		GameData.MirrorDir.NE:
			return incoming_dir == GameData.Dir.DOWN or incoming_dir == GameData.Dir.LEFT
		GameData.MirrorDir.NW:
			return incoming_dir == GameData.Dir.DOWN or incoming_dir == GameData.Dir.RIGHT
		GameData.MirrorDir.SE:
			return incoming_dir == GameData.Dir.UP or incoming_dir == GameData.Dir.LEFT
		GameData.MirrorDir.SW:
			return incoming_dir == GameData.Dir.UP or incoming_dir == GameData.Dir.RIGHT
	return false
			
	
func _create_beam_line(points: PackedVector2Array):
	if points.size() < 2:
		return
	var line := Line2D.new()
	line.points = points
	line.width = 3.0
	line.default_color = GameData.COLOR_LASER_BEAM
	$LaserBeams.add_child(line)
		
		

## Slide Handling 
func _handle_slide(mouse_pos: Vector2i):
	var target := _world_to_grid(mouse_pos)
	if target == dragging_cell:
		return
		
	var data: Dictionary = grid[dragging_cell.x][dragging_cell.y]
	var new_cell := dragging_cell
	
	if drag_axis == "h":
		new_cell = Vector2i(target.x, dragging_cell.y)
	elif drag_axis == "v":
		new_cell = Vector2i(dragging_cell.x, target.y)
		
	# Clamp to slide range
	if drag_axis == "h":
		new_cell.x = clampi(new_cell.x, data["slide_min"], data["slide_max"])
	elif  drag_axis == "v":
		new_cell.y = clampi(new_cell.y, data["slide_min"], data["slide_max"])
		
	if new_cell == dragging_cell:
		return
	if not _is_valid_cell(new_cell):
		return
	if grid[new_cell.x][new_cell.y]["type"] != GameData.PieceType.EMPTY:
		return
		
	# Move piece
	var old_cell := dragging_cell
	grid[new_cell.x][new_cell.y] = data.duplicate()
	grid[old_cell.x][old_cell.y] = _empty_cell()
	dragging_cell = new_cell
	
	_record_action({"action": "slide", "from": old_cell, "to": new_cell})
	_cast_all_lasers()		
		

## Tracking
func _record_action(action_data: Dictionary):
	action_count += 1
	action_history.append(action_data)
	_update_ui()


func undo_action():
	if action_history.is_empty():
		return
	var last: Dictionary = action_history.pop_back()
	
	if last["action"] == "rotate":
		var cell: Vector2i = last["cell"]
		grid[cell.x][cell.y]["mirror_dir"] = last["old_dir"]
		
	elif last["action"] == "slide":
		var from: Vector2i = last["from"]
		var to: Vector2i = last["to"]
		grid[from.x][from.y] = grid[to.x][to.y].duplicate()
		grid[to.x][to.y] = _empty_cell()
		if dragging_cell == to:
			dragging_cell = from
			
	elif last["action"] == "place":
		var cell: Vector2i = last["cell"]
		var inv_index: int = last["inv_index"]
		var piece_data: Dictionary = last["piece_data"]
		grid[cell.x][cell.y] = _empty_cell()
		inventory.insert(inv_index, piece_data)
		selected_inventory_index = -1
		_build_inventory_ui()
		
	action_count -= 1
	_cast_all_lasers()
	_update_ui()
	
	
func reset_level():
	action_count = 0
	action_history.clear()
	_init_grid()
	_place_test_pieces()
	_draw_tiles()
	_cast_all_lasers()
	_update_ui()
	_build_inventory_ui()
	
	
func _update_ui():
	$UI/ActionLabel.text = "Actions: " + str(action_count)
	
	
## Button handlers
func _on_retry():
	$UI/FailPanel.visible = false
	level_active = true
	reset_level()


func _on_menu():
	pass 			#will use when level menu built
	
	
## Inventory System
func _build_inventory_ui():
	var bar := $UI/InventroyBar
	for child in bar.get_children():
		child.queue_free()
		
	$UI/InventroyLabel.visible = inventory.size() > 0
	
	for i in range(inventory.size()):
		var btn := Button.new()
		btn.custom_minimum_size = Vector2(60, 60)
		btn.text = _piece_short_name(inventory[i])
		var idx := i
		btn.pressed.connect(func(): _select_inventory(idx))
		bar.add_child(btn)
		
	_highlight_selected()	
	
	
func _piece_short_name(data: Dictionary) -> String:	
	match data["type"]:
		GameData.PieceType.MIRROR_STATIC_SINGLE: return "S1"
		GameData.PieceType.MIRROR_STATIC_DOUBLE: return "S2"
		GameData.PieceType.MIRROR_ROTATE_SINGLE: return "R1"
		GameData.PieceType.MIRROR_ROTATE_DOUBLE: return "R2"
		GameData.PieceType.MIRROR_SLIDE_H: return "SH"
		GameData.PieceType.MIRROR_SLIDE_V: return "SV"
	return "?"	
	
	
func _select_inventory(index: int):	
	if selected_inventory_index == index:
		selected_inventory_index = -1
	else:
		selected_inventory_index = index
	_highlight_selected()
	
	
func _highlight_selected():
	var bar := $UI/InventroyBar
	for i in range(bar.get_child_count()):
		var btn: Button = bar.get_child(i)
		if i == selected_inventory_index:
			btn.modulate = Color(0.5, 1.0, 0.5)
		else:
			btn.modulate = Color.WHITE
		
		
func _is_hazard_cell(cell: Vector2i) -> bool:
	return grid[cell.x][cell.y]["type"] == GameData.PieceType.HAZARD
	
	
func _place_from_inventory(cell: Vector2i):
	var piece_data: Dictionary = inventory[selected_inventory_index].duplicate()
	grid[cell.x][cell.y] = piece_data
	
	_record_action({"action": "place", "cell": cell, "inv_index": selected_inventory_index, "piece_data": piece_data.duplicate()})
	
	inventory.remove_at(selected_inventory_index)
	selected_inventory_index = -1
	_build_inventory_ui()
	_cast_all_lasers()
		
		
		
		
