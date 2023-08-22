extends CheckButton

func _ready() -> void:
	set_pressed_no_signal(Global.play_music)

func _on_toggled(bpressed: bool) -> void:
	Global.set_setting("play_music", bpressed)
	if bpressed:
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(1))
	else:
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(0))
