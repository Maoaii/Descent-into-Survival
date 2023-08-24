extends Node2D

@export var music: AudioStreamWAV


func _ready():
	if SfxPlayer.get_playback_position() > 0:
		await SfxPlayer.finished
	
	if MusicPlayer.stream != music or MusicPlayer.get_playback_position() <= 0:
		MusicPlayer.stream = music
		MusicPlayer.play()
	
	Global.reset_dialogue_triggers()

func _input(event: InputEvent) -> void:
	if event.is_action_released("pause"):
		call_deferred("_pause")


func _pause() -> void:
	$UI/Paused.pause()
	get_tree().paused = true
