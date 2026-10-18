extends Control

## Ruta de la escena que se carga al pulsar "Jugar".
## Se puede cambiar desde el Inspector.
@export_file("*.tscn") var game_scene: String = "res://ui/main.tscn"

const SETTINGS_PATH := "user://settings.cfg"

const EASTER_EGG_CODE := "errantlab"
var _secret_buffer := ""

@onready var main_panel: VBoxContainer = %MainPanel
@onready var options_panel: VBoxContainer = %OptionsPanel
@onready var play_button: Button = %PlayButton
@onready var options_button: Button = %OptionsButton
@onready var quit_button: Button = %QuitButton
@onready var volume_slider: HSlider = %VolumeSlider
@onready var volume_value: Label = %VolumeValue
@onready var fullscreen_check: CheckButton = %FullscreenCheck
@onready var back_button: Button = %BackButton


func _ready() -> void:
	play_button.pressed.connect(_on_play_pressed)
	options_button.pressed.connect(_on_options_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	back_button.pressed.connect(_on_back_pressed)
	volume_slider.value_changed.connect(_on_volume_changed)
	fullscreen_check.toggled.connect(_on_fullscreen_toggled)
	set_process_unhandled_key_input(true)

	# En web no tiene sentido el botón de salir.
	if OS.has_feature("web"):
		quit_button.hide()

	_load_settings()
	_show_main_panel()
	


func _unhandled_input(event: InputEvent) -> void:
	# Con "ui_cancel" (Esc / B del mando) se vuelve desde Opciones.
	if event.is_action_pressed("ui_cancel") and options_panel.visible:
		_on_back_pressed()
		get_viewport().set_input_as_handled()


# --- Navegación -------------------------------------------------------------

func _show_main_panel() -> void:
	options_panel.hide()
	main_panel.show()
	play_button.grab_focus() # Permite navegar con teclado y mando.


func _show_options_panel() -> void:
	main_panel.hide()
	options_panel.show()
	volume_slider.grab_focus()


# --- Botones ----------------------------------------------------------------

func _on_play_pressed() -> void:
	if ResourceLoader.exists(game_scene):
		get_tree().change_scene_to_file(game_scene)
	else:
		push_warning("No existe la escena del juego: %s. Cambia 'game_scene' en el Inspector." % game_scene)


func _on_options_pressed() -> void:
	_show_options_panel()


func _on_back_pressed() -> void:
	_save_settings()
	_show_main_panel()


func _on_quit_pressed() -> void:
	_save_settings()
	get_tree().quit()


# --- Opciones ---------------------------------------------------------------

func _on_volume_changed(value: float) -> void:
	_apply_volume(value)


func _on_fullscreen_toggled(enabled: bool) -> void:
	_apply_fullscreen(enabled)


func _apply_volume(value: float) -> void:
	# value va de 0 a 100.
	var bus := AudioServer.get_bus_index("Master")
	AudioServer.set_bus_mute(bus, value <= 0.0)
	AudioServer.set_bus_volume_db(bus, linear_to_db(value / 100.0))
	volume_value.text = "%d%%" % int(value)


func _apply_fullscreen(enabled: bool) -> void:
	if enabled:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


# --- Guardado de opciones ---------------------------------------------------

func _save_settings() -> void:
	var config := ConfigFile.new()
	config.set_value("audio", "volume", volume_slider.value)
	config.set_value("video", "fullscreen", fullscreen_check.button_pressed)
	config.save(SETTINGS_PATH)


func _load_settings() -> void:
	var config := ConfigFile.new()
	var volume := 80.0
	var fullscreen := false
	if config.load(SETTINGS_PATH) == OK:
		volume = config.get_value("audio", "volume", volume)
		fullscreen = config.get_value("video", "fullscreen", fullscreen)

	volume_slider.set_value_no_signal(volume)
	fullscreen_check.set_pressed_no_signal(fullscreen)
	_apply_volume(volume)
	_apply_fullscreen(fullscreen)

func _unhandled_key_input(event: InputEvent) -> void:
	if not event is InputEventKey:
		return
	var key:= event as InputEventKey
	if not key.pressed or key.echo or key.unicode < 32:
		return
	var character := char(key.unicode).to_lower()
	
	_secret_buffer = (_secret_buffer + character).right(EASTER_EGG_CODE.length())
	
	if _secret_buffer == EASTER_EGG_CODE:
		_secret_buffer = ""
		_launch_sandbox()
		get_viewport().set_input_as_handled()

func _launch_sandbox() -> void:
	var process_id: int =-1
	
	if OS.has_feature("editor"):
		var demo_path := ProjectSettings.globalize_path("res://").path_join("../nuevo-proyecto-de-juego").simplify_path()
		if not FileAccess.file_exists(
		demo_path.path_join("project.godot")):
			push_warning("No se encontró el proyecto Sandbox.")
			return
		process_id = OS.create_process(
			OS.get_executable_path(),
			PackedStringArray(["--path", demo_path])
		)
	else:
		var game_folder := OS.get_executable_path().get_base_dir()
		var demo_exe := game_folder.path_join("ErrantSandbox.exe")
		if not FileAccess.file_exists(demo_exe):
			push_warning("No se encontró ErrantSandbox.exe.")
			return
			
		process_id = OS.create_process(
			demo_exe,
			PackedStringArray()
		)
	if process_id == -1:
		push_warning("No se spudo iniciar el modo secreto")
