extends Node2D

@export var music: AudioStreamWAV

var dead: bool = false

func _ready():
	DialogueManager.show_dialogue_balloon(load("res://dialogues/game_start.dialogue"), "start", 8)
	
	if SfxPlayer.get_playback_position() > 0:
		await SfxPlayer.finished
	
	if MusicPlayer.stream != music or MusicPlayer.get_playback_position() <= 0:
		MusicPlayer.stream = music
		MusicPlayer.play()
	
	Global.reset_dialogue_triggers()

func _input(event: InputEvent) -> void:
	if not dead and event.is_action_released("pause"):
		call_deferred("_pause")


func _pause() -> void:
	$UI/Paused.pause()
	get_tree().paused = true

func _death() -> void:
	$UI/DeathScreen.appear()
	get_tree().paused = true
	dead = true
