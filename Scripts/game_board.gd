extends Node2D

# vars
var grid_width: int = 8
var grid_height: int = 8
var grid: Array = [] 			# Pieces data




func _ready() -> void:
	_init_grid()
	_draw_tiles()


func _init_grid():
	grid = []
	for x in range(grid_width):
		var col := []
		for y in range(grid_height):
			col.append(GameData.PieceType.EMPTY)
		grid.append(col)

func _draw_tiles():
	
	
func _grid_to_world():
	
	
func _cell_center():
	
	
func _world_to_grid():
	
	
func _is_valid_cell():
	
	
func _draw():
