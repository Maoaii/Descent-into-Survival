extends VFlowContainer

@export_file() var gameplay_scene: String
@export_file() var settings_scene: String

func _ready() -> void:
	get_children()[0].grab_focus()
	
	if !OS.has_feature("pc"):
		$Quit.hide()

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_settings_pressed() -> void:
	SceneChangingMachine.change_scene(settings_scene)

func _on_start_pressed() -> void:
	MusicPlayer.stop()
	SceneChangingMachine.change_scene(gameplay_scene)
