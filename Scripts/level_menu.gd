extends Control



func _ready() -> void:
	pass
	
	
func _build_level_buttons():
	
	
	
func _on_level_select(level_num: int):
	LevelData.current_level = level_num
	get_tree().change_scene_to_file("res://Scenes/game_board.tscn")
	

func _on_back():
	get_tree().change_scene_to_file("res://Scenes/title_screen.tscn")
