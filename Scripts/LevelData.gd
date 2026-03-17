extends Node

var current_level: int = 1
var level_progress: Dictionary = {}



func _ready() -> void:
	# init all levels as locked except first lvl
	for i in range(1, get_level_count() + 1):
		level_progress[i] = {"status": GameData.LevelStatus.LOCKED, "moves": 0}
	levels[1]["status"] = GameData.LevelStatus.INCOMPLETE	


func get_level_count() -> int:
	return levels.size()
	

func complete_level(level_num: int, moves: int):
	level_progress[level_num]["status"] = GameData.LevelStatus.COMPLETE
	var prev_moves: int = level_progress[level_num]["moves"]
	if prev_moves == 0 or moves < prev_moves:
		level_progress[level_num]["moves"] = moves
	# unlock next level
	if level_num < get_level_count():
		if level_progress[level_num + 1]["status"] == GameData.LevelStatus.LOCKED:
			level_progress[level_num + 1]["status"] = GameData.LevelStatus.INCOMPLETE
	

func get_level(level_num: int) -> Dictionary:
	return levels[level_num - 1]
	
	
	
var levels: Array = [
	# Lvl 1: 1 static double mirror
	{
		"width": 6,
		"height": 6,
		"pieces": [
			{"x": 0, "y": 2, "type": "LASER", "laser_dir": "RIGHT", "color_index": 0},
			{"x": 3, "y": 2, "type": "MIRROR_STATIC_DOUBLE", "mirror_dir": "NE", "double_sided": true},
			{"x": 3, "y": 5, "type": "GOAL", "color_index": 0},		
		],
		"inventory": []
	},
	
	# Lvl 2: 1 static single mirror
	{
		"width": 6,
		"height": 6,
		"pieces": [
			{"x": 0, "y": 1, "type": "LASER", "laser_dir": "RIGHT", "color_index": 0},
			{"x": 4, "y": 1, "type": "MIRROR_STATIC_SINGLE", "mirror_dir": "NE", "double_sided": false},
			{"x": 4, "y": 4, "type": "GOAL", "color_index": 0},		
		],
		"inventory": []
	},
	
	# lVL 3: ROTATABLE MIRROR
	{
		"width": 6,
		"height": 6,
		"pieces": [
			{"x": 0, "y": 2, "type": "LASER", "laser_dir": "RIGHT", "color_index": 0},
			{"x": 3, "y": 3, "type": "MIRROR_ROTATE_SINGLE", "mirror_dir": "NW", "double_sided": false},
			{"x": 3, "y": 0, "type": "GOAL", "color_index": 0},		
		],
		"inventory": []
	},
	
	# lVL 4: ROTATABLE MIRROR AND BARRIER
	{
		"width": 7,
		"height": 7,
		"pieces": [
			{"x": 0, "y": 3, "type": "LASER", "laser_dir": "RIGHT", "color_index": 0},
			{"x": 6, "y": 3, "type": "BARRIER"},
			{"x": 3, "y": 3, "type": "MIRROR_ROTATE_DOUBLE", "mirror_dir": "NW", "double_sided": true},
			{"x": 3, "y": 0, "type": "MIRROR_STATIC_DOUBLE", "mirror_dir": "NW", "double_sided": true},
			{"x": 6, "y": 0, "type": "GOAL", "color_index": 0},		
		],
		"inventory": []
	},
	
	# lVL 5: HORIZONTAL SLIDE MIRROR
	{
		"width": 7,
		"height": 7,
		"pieces": [
			{"x": 0, "y": 3, "type": "LASER", "laser_dir": "DOWN", "color_index": 0},
			{"x": 0, "y": 3, "type": "MIRROR_SLIDE_H", "mirror_dir": "NW", "double_sided": true, "slide_axis": "h", "slide_min": 0, "slide_max": 4},
			{"x": 3, "y": 6, "type": "GOAL", "color_index": 0},
			{"x": 6, "y": 3, "type": "MIRROR_STATIC_DOUBLE", "mirror_dir": "NE", "double_sided": true},		
		],
		"inventory": []
	},
	
	# Lvl 6: vertical slide mirror and hazard
	{
		"width": 7,
		"height": 7,
		"pieces": [
			{"x": 0, "y": 3, "type": "LASER", "laser_dir": "DOWN", "color_index": 0},
			{"x": 3, "y": 3, "type": "MIRROR_STATIC_DOUBLE", "mirror_dir": "NE", "double_sided": true},	
			{"x": 3, "y": 5, "type": "MIRROR_SLIDE_V", "mirror_dir": "NW", "double_sided": true, "slide_axis": "v", "slide_min": 4, "slide_max": 6},
			{"x": 4, "y": 5, "type": "HAZARD"},
			{"x": 6, "y": 5, "type": "GOAL", "color_index": 0},
				
		],
		"inventory": []
	},
	
	# Lvl 7: Invetory 
	{
		"width": 7,
		"height": 7,
		"pieces": [
			{"x": 0, "y": 3, "type": "LASER", "laser_dir": "RIGHT", "color_index": 0},
			{"x": 6, "y":05, "type": "GOAL", "color_index": 0},
			{"x": 4, "y": 3, "type": "BARRIER"},
		],
		"inventory": [
			{"type": "MIRROR_ROTATE_DOUBLE", "mirror_dir": "NE", "double_sided": true},
			{"type": "MIRROR_ROTATE_DOUBLE", "mirror_dir": "NW", "double_sided": true},
		]
	},
	
	
]
