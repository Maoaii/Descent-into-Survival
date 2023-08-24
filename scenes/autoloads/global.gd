extends Node

var master_volume: float = 1
var play_sfx = true
var sfx_volume: float = 1
var play_music = true
var music_volume: float = 1
var fullscreen = false
var version = null
var show_debug_ui = false
const SCENE_MAIN_MENU = "res://scenes/main_menu/main_menu.tscn"
const EXPORT_CONFIG_FILE := "res://export.cfg"
const EXPORT_CONFIG_METADATA_SECTION := "metadata"
const SETTINGS_FILE := "user://settings.cfg"
const CONFIG_SETTINGS_SECTION := "settings"

var player_first_time_stunned: bool = false

func _ready() -> void:
	print_debug("Global ready")
	Engine.max_fps = 60
	load_settings()
	load_game_metadata()
	
	# hidden by default, can be toggled on in debug mode
	get_tree().call_group("debug_ui", "hide")

func load_settings() -> void:
	var config = ConfigFile.new()
	var load_res = config.load(SETTINGS_FILE)

	if load_res != OK:
		print("failed to load settings")
		return

	for setting_key in config.get_section_keys(CONFIG_SETTINGS_SECTION):
		set_setting(setting_key, config.get_value(CONFIG_SETTINGS_SECTION, setting_key), false)

## persist all settings to disk
## add a new setting in the array to ensure it persists
func save_settings() -> void:
	var config = ConfigFile.new()
	for setting in ["fullscreen", "master_volume", "music_volume", "sfx_volume", "play_sfx", "play_music"]:
		config.set_value(CONFIG_SETTINGS_SECTION, setting, self[setting])
	config.save(SETTINGS_FILE)

## val is a bool representing whether or not to toggle on fullscreen
func set_fullscreen(val: bool) -> void:
	fullscreen = val
	if fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

## Assigns the value to the Global setting variable.
## Defaults to saving all settings after one gets set, but can be disabled
## with the `save` argument.
func set_setting(setting: String, val, save := true) -> void:
	self[setting] = val
	if setting == "fullscreen":
		set_fullscreen(val)

	if save:
		save_settings()

## sets the version property from the export.cfg file
func load_game_metadata() -> void:
	var config := ConfigFile.new()
	var load_res := config.load(EXPORT_CONFIG_FILE)

	if load_res != OK:
		print("failed to load game metadata")
		return

	version = config.get_value(EXPORT_CONFIG_METADATA_SECTION, "version")

func _input(event: InputEvent) -> void:
	if OS.is_debug_build() and event.is_action_pressed("debug_toggle_ui"):
		show_debug_ui = !show_debug_ui
		print_debug("debug UI toggled: " + str(show_debug_ui))
		if show_debug_ui:
			get_tree().call_group("debug_ui", "show")
		else:
			get_tree().call_group("debug_ui", "hide")

func reset_dialogue_triggers() -> void:
	player_first_time_stunned = false

func player_stunned() -> void:
	if not player_first_time_stunned:
		player_first_time_stunned = true
		DialogueManager.show_dialogue_balloon(load("res://dialogues/stunned.dialogue"), "start", 6)
