extends Node

var current_level: int = 1
var level_progress: Dictionary = {}



func _ready() -> void:
	# init all levels as locked except first lvl
	for i in range(1, get_level_count() + 1):
		if i == 1:
			level_progress[i] = {"status": GameData.LevelStatus.INCOMPLETE, "moves": 0}
		else:
			level_progress[i] = {"status": GameData.LevelStatus.LOCKED, "moves": 0}


func get_level_count() -> int:
	return levels.size()
	

func get_progress(level_num: int) -> Dictionary:
	if not level_progress.has(level_num):
		if level_num == 1:
			level_progress[level_num] = {"status": GameData.LevelStatus.INCOMPLETE, "moves": 0}
		else:
			level_progress[level_num] = {"status": GameData.LevelStatus.LOCKED, "moves": 0}
	
	return level_progress[level_num]
	

func complete_level(level_num: int, moves: int):
	level_progress[level_num]["status"] = GameData.LevelStatus.COMPLETE
	var prev_moves: int = level_progress[level_num]["moves"]
	if prev_moves == 0 or moves < prev_moves:
		level_progress[level_num]["moves"] = moves
	# unlock next level
	if level_num < get_level_count():
		var next_progress := get_progress(level_num + 1)
		if next_progress["status"] == GameData.LevelStatus.LOCKED:
			next_progress["status"] = GameData.LevelStatus.INCOMPLETE
				

func get_level(level_num: int) -> Dictionary:
	return levels[level_num - 1]
	

	
var levels: Array = [
	# Lvl 1: 1 static double mirror
	#{
		#"width": 6,
		#"height": 6,
		#"pieces": [
			#{"x": 0, "y": 2, "type": "LASER", "laser_dir": "RIGHT", "color_index": 0},
			#{"x": 3, "y": 2, "type": "MIRROR_ROTATE_DOUBLE", "mirror_dir": "NW", "double_sided": true},
			#{"x": 3, "y": 5, "type": "GOAL", "color_index": 0},		
		#],
		#"inventory": []
	#},
	
		{
		"width": 8,
		"height": 8,
		"pieces": [
			{"x": 0, "y": 6, "type": "LASER", "laser_dir": "RIGHT", "color_index": 0},
			{"x": 0, "y": 2, "type": "LASER", "laser_dir": "RIGHT", "color_index": 1},
			{"x": 4, "y": 2, "type": "MIRROR_ROTATE_DOUBLE", "mirror_dir": "NW", "double_sided": true},	
			{"x": 3, "y": 0, "type": "MIRROR_SLIDE_H", "mirror_dir": "NE", "double_sided": true, "slide_axis": "h", "slide_min": 1, "slide_max": 5},
			{"x": 5, "y": 4, "type": "MIRROR_SLIDE_V", "mirror_dir": "NW", "double_sided": true, "slide_axis": "v", "slide_min": 3, "slide_max": 7},
			{"x": 3, "y": 7, "type": "MIRROR_ROTATE_SINGLE", "mirror_dir": "NW", "double_sided": false},	
			{"x": 3, "y": 4, "type": "HAZARD"},
			{"x": 6, "y": 2, "type": "BOMB"},
			{"x": 7, "y": 7, "type": "GOAL", "color_index": 1},
			{"x": 7, "y": 0, "type": "GOAL", "color_index": 0},
			
				
		],
		"inventory": [
			{"type": "MIRROR_ROTATE_DOUBLE", "mirror_dir": "NE", "double_sided": true},
		]
	},
	
	
	# Lvl 2: 1 static single mirror
	{
		"width": 6,
		"height": 6,
		"pieces": [
			{"x": 0, "y": 1, "type": "LASER", "laser_dir": "RIGHT", "color_index": 0},
			{"x": 4, "y": 1, "type": "MIRROR_ROTATE_SINGLE", "mirror_dir": "SE", "double_sided": false},
			{"x": 4, "y": 4, "type": "GOAL", "color_index": 0},		
		],
		"inventory": []
	},
	
	# lVL 3: ROTATABLE MIRROR
	{
		"width": 7,
		"height": 7,
		"pieces": [
			{"x": 0, "y": 3, "type": "LASER", "laser_dir": "RIGHT", "color_index": 0},
			{"x": 3, "y": 3, "type": "MIRROR_STATIC_DOUBLE", "mirror_dir": "NE", "double_sided": true},
			{"x": 3, "y": 6, "type": "MIRROR_ROTATE_DOUBLE", "mirror_dir": "NW", "double_sided": true},
			{"x": 6, "y": 6, "type": "GOAL", "color_index": 0},		
		],
		"inventory": []
	},
	
	# lVL 4: ROTATABLE MIRROR AND BARRIER
	{
		"width": 7,
		"height": 7,
		"pieces": [
			{"x": 0, "y": 0, "type": "LASER", "laser_dir": "RIGHT", "color_index": 0},
			{"x": 0, "y": 3, "type": "MIRROR_STATIC_DOUBLE", "mirror_dir": "NE", "double_sided": false},
			{"x": 4, "y": 3, "type": "MIRROR_ROTATE_DOUBLE", "mirror_dir": "NE", "double_sided": true},
			{"x": 4, "y": 0, "type": "MIRROR_ROTATE_DOUBLE", "mirror_dir": "NW", "double_sided": true},
			{"x": 6, "y": 3, "type": "BARRIER"},
			{"x": 0, "y": 1, "type": "GOAL", "color_index": 0},		
		],
		"inventory": []
	},
	
	# lVL 5: HORIZONTAL SLIDE MIRROR
	{
		"width": 7,
		"height": 7,
		"pieces": [
			{"x": 0, "y": 3, "type": "LASER", "laser_dir": "RIGHT", "color_index": 0},
			{"x": 1, "y": 3, "type": "MIRROR_SLIDE_H", "mirror_dir": "NE", "double_sided": true, "slide_axis": "h", "slide_min": 1, "slide_max": 5},
			{"x": 4, "y": 6, "type": "GOAL", "color_index": 0},
		],
		"inventory": []
	},
	
	# Lvl 6: vertical slide mirror and hazard
	{
		"width": 7,
		"height": 7,
		"pieces": [
			{"x": 0, "y": 3, "type": "LASER", "laser_dir": "RIGHT", "color_index": 0},
			{"x": 3, "y": 3, "type": "MIRROR_STATIC_DOUBLE", "mirror_dir": "NE", "double_sided": true},	
			{"x": 3, "y": 6, "type": "MIRROR_SLIDE_V", "mirror_dir": "NE", "double_sided": true, "slide_axis": "v", "slide_min": 4, "slide_max": 6},
			{"x": 5, "y": 4, "type": "HAZARD"},
			{"x": 6, "y": 4, "type": "GOAL", "color_index": 0},
				
		],
		"inventory": []
	},
	
	# Lvl 7: Invetory 
	{
		"width": 7,
		"height": 7,
		"pieces": [
			{"x": 0, "y": 3, "type": "LASER", "laser_dir": "RIGHT", "color_index": 0},
			{"x": 3, "y": 3, "type": "BARRIER"},
			{"x": 6, "y": 0, "type": "GOAL", "color_index": 0},
		],
		"inventory": [
			{"type": "MIRROR_ROTATE_DOUBLE", "mirror_dir": "NW", "double_sided": true},
			{"type": "MIRROR_ROTATE_DOUBLE", "mirror_dir": "NW", "double_sided": true},
		]
	},
	
	# Lvl 8: Bombs
	{
		"width": 8,
		"height": 7,
		"pieces": [
			{"x": 0, "y": 3, "type": "LASER", "laser_dir": "RIGHT", "color_index": 0},
			{"x": 4, "y": 3, "type": "MIRROR_ROTATE_DOUBLE", "mirror_dir": "NW", "double_sided": true},	
			{"x": 4, "y": 0, "type": "MIRROR_ROTATE_DOUBLE", "mirror_dir": "NE", "double_sided": true},
			{"x": 4, "y": 6, "type": "BOMB"},
			{"x": 7, "y": 0, "type": "GOAL", "color_index": 0},
				
		],
		"inventory": []
	},
	
	# Lvl 9: Multiple lasers
	{
		"width": 8,
		"height": 8,
		"pieces": [
			{"x": 0, "y": 1, "type": "LASER", "laser_dir": "RIGHT", "color_index": 0},
			{"x": 0, "y": 6, "type": "LASER", "laser_dir": "RIGHT", "color_index": 1},
			{"x": 4, "y": 1, "type": "MIRROR_ROTATE_DOUBLE", "mirror_dir": "NW", "double_sided": true},	
			{"x": 5, "y": 6, "type": "MIRROR_ROTATE_DOUBLE", "mirror_dir": "NE", "double_sided": true},
			{"x": 4, "y": 7, "type": "GOAL", "color_index": 0},
			{"x": 5, "y": 0, "type": "GOAL", "color_index": 1},
			{"x": 6, "y": 1, "type": "BOMB"},
				
		],
		"inventory": []
	},
	
	#10: All elements
	{
		"width": 8,
		"height": 8,
		"pieces": [
			{"x": 0, "y": 6, "type": "LASER", "laser_dir": "RIGHT", "color_index": 0},
			{"x": 0, "y": 2, "type": "LASER", "laser_dir": "RIGHT", "color_index": 1},
			{"x": 3, "y": 4, "type": "MIRROR_ROTATE_DOUBLE", "mirror_dir": "NW", "double_sided": true},	
			{"x": 3, "y": 0, "type": "MIRROR_SLIDE_H", "mirror_dir": "NE", "double_sided": true, "slide_axis": "h", "slide_min": 1, "slide_max": 5},
			{"x": 5, "y": 4, "type": "MIRROR_SLIDE_V", "mirror_dir": "NW", "double_sided": true, "slide_axis": "v", "slide_min": 3, "slide_max": 7},
			{"x": 3, "y": 7, "type": "MIRROR_ROTATE_SINGLE", "mirror_dir": "NW", "double_sided": false},	
			{"x": 3, "y": 4, "type": "HAZARD"},
			{"x": 6, "y": 2, "type": "BOMB"},
			{"x": 7, "y": 7, "type": "GOAL", "color_index": 1},
			{"x": 7, "y": 0, "type": "GOAL", "color_index": 0},
			
				
		],
		"inventory": [
			{"type": "MIRROR_ROTATE_DOUBLE", "mirror_dir": "NE", "double_sided": true},
		]
	},
	
]
