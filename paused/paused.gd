extends Control

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("pause"):
		call_deferred("_resume")

func _resume() -> void:
	hide()
	get_parent().get_tree().paused = false
	get_tree().get_first_node_in_group("Section").focus_first_entity()

func pause() -> void:
	get_parent().get_tree().paused = true
	#Sound.play_sfx($"../SelectSfx")
	show()
	$PauseOptions.focus()
