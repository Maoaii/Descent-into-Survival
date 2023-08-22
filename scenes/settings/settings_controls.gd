extends VFlowContainer

func _ready() -> void:
	for child in get_children():
		if child.visible:
			child.grab_focus()
			return

func _process(_delta: float) -> void:
	$MasterVolume.value = Global.master_volume
	$MusicVolume.value = Global.music_volume
	$SFXVolume.value = Global.sfx_volume

func _on_master_volume_value_changed(value: float) -> void:
	Global.set_setting("master_volume", value)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(Global.master_volume))
	

func _on_music_volume_value_changed(value: float) -> void:
	Global.set_setting("music_volume", value)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(Global.music_volume))
	

func _on_sfx_volume_value_changed(value: float) -> void:
	Global.set_setting("sfx_volume", value)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Sound"), linear_to_db(Global.sfx_volume))
	
