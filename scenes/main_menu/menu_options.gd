extends VBoxContainer

@export_file() var gameplay_scene: String
@export_file() var settings_scene: String

func _ready() -> void:
	get_children()[0].grab_focus()
	
	if !OS.has_feature("pc"):
		$Quit.hide()

func _on_quit_pressed() -> void:
	SfxPlayer.stream = load("res://sound/sfx/Game Jam_Quit.wav")
	SfxPlayer.play()
	SceneChangingMachine.quit()

func _on_settings_pressed() -> void:
	SceneChangingMachine.change_scene(settings_scene)

func _on_start_pressed() -> void:
	MusicPlayer.stop()
	SfxPlayer.stream = load("res://sound/sfx/Game Jam_Start.wav")
	SfxPlayer.play()
	SceneChangingMachine.change_scene(gameplay_scene)
