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
	
	
	
	
	
]
