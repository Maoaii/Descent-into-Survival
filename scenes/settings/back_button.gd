extends Button

func _on_pressed() -> void:
	SceneChangingMachine.change_scene(Global.SCENE_MAIN_MENU)
