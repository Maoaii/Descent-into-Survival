class_name Menu
extends Control


@export var music: AudioStreamWAV


func _ready():
	if MusicPlayer.stream != music or MusicPlayer.get_playback_position() <= 0:
		MusicPlayer.stream = music
		MusicPlayer.play()
	
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(Global.master_volume))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(Global.music_volume))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Sound"), linear_to_db(Global.sfx_volume))
