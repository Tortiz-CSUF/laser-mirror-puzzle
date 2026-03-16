extends Node2D

# vars
var grid_width: int = 8
var grid_height: int = 8
var grid: Array = [] 			# Pieces data




func _ready() -> void:
	_init_grid()
	_place_test_pieces()
	_draw_tiles()
	_cast_all_lasers()


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
	
	# Double sides mirror at (4,3)
	grid[4][3]["type"] = GameData.PieceType.MIRROR_STATIC_DOUBLE
	grid[4][3]["mirror_dir"] = GameData.MirrorDir.NE
	grid[4][3]["double_sided"] = true
	
	# Goal at (4,6)
	grid[4][6]["type"] = GameData.PieceType.GOAL
	grid[4][6]["color_index"] = 0


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
		
