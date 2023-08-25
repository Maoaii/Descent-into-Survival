extends VFlowContainer

func _ready() -> void:
	focus()
	
	if !OS.has_feature("pc"):
		$Quit.hide()

func focus() -> void:
	get_children()[0].grab_focus()

func _on_quit_pressed() -> void:
	var root = get_tree().get_root().get_tree()
	root.paused = false
	SfxPlayer.stream = load("res://sound/sfx/Game Jam_Quit.wav")
	SfxPlayer.play()
	SceneChangingMachine.quit()

func _on_main_menu_pressed() -> void:
	var root = get_tree().get_root().get_tree()
	root.paused = false
	SceneChangingMachine.change_scene(Global.SCENE_MAIN_MENU)
	SfxPlayer.stream = load("res://sound/sfx/Game Jam_Quit.wav")
	SfxPlayer.play()
