extends Control



func _ready() -> void:
	$PlayButton.pressed.connect(_on_play)
	$InstructionsButton.pressed.connect(_on_instructions)


func _on_play():
	get_tree().change_scene_to_file("res://Scenes/title_screen.tscn")
	

func _on_instructions():
	get_tree().change_scene_to_file("")
