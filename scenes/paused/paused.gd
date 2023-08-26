extends Control

var dead: bool = false

func _input(event: InputEvent) -> void:
	if not dead and event.is_action_released("pause"):
		call_deferred("_resume")

func _resume() -> void:
	hide()
	get_parent().get_tree().paused = false

func pause() -> void:
	Sound.play_sfx($"../../SelectSfx")
	show()
	$PauseOptions.focus()
