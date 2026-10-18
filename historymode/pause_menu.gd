class_name PauseMenu
extends CanvasLayer
## Menú superpuesto reutilizable.
## Sirve como menú de pausa (Esc) y como pantalla de victoria.
## Se construye por código, así que no necesita escena propia.

const MAIN_MENU_SCENE := "res://main_menu.tscn"

var _root: Control
var _title: Label
var _subtitle: Label
var _resume_button: Button
var _restart_button: Button
var _menu_button: Button


func _ready() -> void:
	layer = 10
	# Debe seguir funcionando mientras el juego está en pausa.
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_ui()
	_root.hide()


func is_open() -> bool:
	return _root.visible


## Muestra el menú y pausa el juego.
## allow_resume = false oculta "Continuar" (por ejemplo, en la pantalla de victoria).
## subtitle es un texto opcional bajo el título (por ejemplo, el tiempo).
func open(
	title: String,
	allow_resume: bool,
	restart_text: String = "Reiniciar",
	subtitle: String = ""
) -> void:
	_title.text = title
	_subtitle.text = subtitle
	_subtitle.visible = subtitle != ""
	_resume_button.visible = allow_resume
	_restart_button.text = restart_text
	_root.show()
	get_tree().paused = true
	# Permite navegar con teclado y mando.
	if allow_resume:
		_resume_button.grab_focus()
	else:
		_restart_button.grab_focus()


## Oculta el menú y reanuda el juego.
func close() -> void:
	_root.hide()
	get_tree().paused = false


func _unhandled_input(event: InputEvent) -> void:
	# Esc (o B del mando) cierra la pausa. En la pantalla de victoria no hace nada.
	if _root.visible and _resume_button.visible and event.is_action_pressed("ui_cancel"):
		close()
		get_viewport().set_input_as_handled()


# --- Construcción de la interfaz --------------------------------------------

func _build_ui() -> void:
	_root = Control.new()
	add_child(_root)
	_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	# Fondo oscuro semitransparente (también bloquea los clics hacia el juego).
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.6)
	_root.add_child(dim)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var center := CenterContainer.new()
	_root.add_child(center)
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 16)
	center.add_child(box)

	_title = Label.new()
	_title.add_theme_font_size_override("font_size", 56)
	_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(_title)

	_subtitle = Label.new()
	_subtitle.add_theme_font_size_override("font_size", 26)
	_subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_subtitle.hide()
	box.add_child(_subtitle)

	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 16)
	box.add_child(spacer)

	_resume_button = _make_button("Continuar", close, box)
	_restart_button = _make_button("Reiniciar", _on_restart_pressed, box)
	_menu_button = _make_button("Menú principal", _on_main_menu_pressed, box)


func _make_button(text: String, callback: Callable, parent: Control) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(280, 56)
	button.add_theme_font_size_override("font_size", 24)
	button.pressed.connect(callback)
	parent.add_child(button)
	return button


# --- Botones ----------------------------------------------------------------

func _on_restart_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_main_menu_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(MAIN_MENU_SCENE)
