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
		"mirror_dir": GameData.MirrorDIr
	}


func _init_grid():
	grid = []
	for x in range(grid_width):
		var col := []
		for y in range(grid_height):
			col.append(GameData.PieceType.EMPTY)
		grid.append(col)

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
	
	
