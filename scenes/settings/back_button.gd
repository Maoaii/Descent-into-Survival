extends Button

func _on_pressed() -> void:
	SfxPlayer.stream = load("res://sound/sfx/Game Jam_Quit.wav")
	SfxPlayer.play()
	SceneChangingMachine.change_scene(Global.SCENE_MAIN_MENU)
