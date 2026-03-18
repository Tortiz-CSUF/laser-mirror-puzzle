extends Control



func _ready() -> void:
	$BackButton.pressed.connect(_on_back)
	_build_level_buttons()	
	
func _build_level_buttons():
	var grid_container := $LevelGrid
	for child in grid_container.get_children():
		child.queue_free()
	
	for i in range(1, LevelData.get_level_count() + 1):
		var btn := Button.new()
		btn.custom_minimum_size = Vector2(140, 80)
		var progress: Dictionary = LevelData.get_progress(i)
		var status: int = progress["status"]
		
		if status == GameData.LevelStatus.LOCKED:
			btn.text = "Level " + str(i) + "\nLocked"
			btn.disabled = true
		elif status == GameData.LevelStatus.INCOMPLETE:
			btn.text = "Level " + str(i) + "\nIncomplete"
			var level_num := i 
			btn.pressed.connect(func(): _on_level_select(level_num))
		elif status == GameData.LevelStatus.COMPLETE:
			btn.text = "Level " + str(i) + "\nMoves: " + str(progress["moves"])
			
		grid_container.add_child(btn)	
	
	
func _on_level_select(level_num: int):
	LevelData.current_level = level_num
	get_tree().change_scene_to_file("res://Scenes/game_board.tscn")
	


func _on_back():
	get_tree().change_scene_to_file("res://Scenes/title_screen.tscn")
