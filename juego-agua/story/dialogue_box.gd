class_name DialogueBox
extends CanvasLayer
## Cuadro de diálogo con efecto de máquina de escribir.
## Se construye por código (igual que PauseMenu), así que no necesita escena.
## Mientras está abierto, el juego queda en pausa.
##
## Uso:      dialogue.play("mara_first")   # el id está en story.gd
## Avanzar:  E, Espacio, Enter o clic. Si el texto aún se está escribiendo,
##           lo muestra completo.
## Al terminar activa las banderas/objetivo del diálogo y emite "finished".

signal finished(dialogue_id: String)

const CHARS_PER_SECOND := 45.0

var _root: Control
var _name_label: Label
var _text_label: Label
var _hint_label: Label

var _dialogue_id: String = ""
var _data: Dictionary = {}
var _lines: Array = []
var _line_index: int = 0
var _typed: float = 0.0
var _open_frame: int = -1


func _ready() -> void:
	layer = 5
	# Debe seguir funcionando mientras el juego está en pausa.
	process_mode = Node.PROCESS_MODE_ALWAYS
	add_to_group("dialogue_box")
	_build_ui()
	_root.hide()


func is_open() -> bool:
	return _root.visible


## Reproduce el diálogo con ese id (definido en story.gd).
func play(dialogue_id: String) -> void:
	if is_open():
		return

	var data: Dictionary = Story.get_dialogue(dialogue_id)
	var lines: Array = data.get("lines", [])
	if lines.is_empty():
		return

	_dialogue_id = dialogue_id
	_data = data
	_lines = lines
	_line_index = 0
	# Evita que la misma pulsación que abrió el diálogo lo avance de inmediato.
	_open_frame = Engine.get_process_frames()

	var speaker: String = data.get("speaker", "")
	_name_label.text = speaker
	_name_label.visible = speaker != ""

	_root.show()
	get_tree().paused = true
	_show_line()


func _process(delta: float) -> void:
	if _is_line_complete():
		return

	_typed += delta * CHARS_PER_SECOND
	if _is_line_complete():
		_finish_typing()
	else:
		_text_label.visible_characters = int(_typed)


func _unhandled_input(event: InputEvent) -> void:
	if not _root.visible:
		return
	if Engine.get_process_frames() == _open_frame:
		return

	if (
		event.is_action_pressed("interact")
		or event.is_action_pressed("ui_accept")
		or _is_left_click(event)
	):
		get_viewport().set_input_as_handled()
		_advance()


# --- Líneas -----------------------------------------------------------------

func _show_line() -> void:
	_text_label.text = str(_lines[_line_index])
	_text_label.visible_characters = 0
	_typed = 0.0

	var is_last := _line_index >= _lines.size() - 1
	_hint_label.text = "[E] cerrar" if is_last else "[E] continuar"
	_hint_label.modulate.a = 0.0

	if _text_label.text.is_empty():
		_finish_typing()


func _is_line_complete() -> bool:
	return _typed >= float(_text_label.text.length())


func _finish_typing() -> void:
	_typed = float(_text_label.text.length())
	_text_label.visible_characters = -1
	_hint_label.modulate.a = 1.0


func _advance() -> void:
	# Si aún se está escribiendo, primero muestra la línea completa.
	if not _is_line_complete():
		_finish_typing()
		return

	_line_index += 1
	if _line_index >= _lines.size():
		_close()
	else:
		_show_line()


func _close() -> void:
	_root.hide()
	get_tree().paused = false

	# Lo que "pasó" por haber visto este diálogo.
	Story.set_flag("done_" + _dialogue_id)

	var extra_flag: String = _data.get("flag", "")
	if extra_flag != "":
		Story.set_flag(extra_flag)

	var new_objective: String = _data.get("objective", "")
	if new_objective != "":
		Story.objective = new_objective

	# Avisa a quien le interese (puertas, HUD...) que la historia avanzó.
	get_tree().call_group("story_listeners", "on_story_changed")
	finished.emit(_dialogue_id)


func _is_left_click(event: InputEvent) -> bool:
	var mouse := event as InputEventMouseButton
	return mouse != null and mouse.pressed and mouse.button_index == MOUSE_BUTTON_LEFT


# --- Construcción de la interfaz --------------------------------------------

func _build_ui() -> void:
	_root = Control.new()
	_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_root)
	_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var panel := PanelContainer.new()
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(panel)

	# Pegado abajo, con margen a los lados, y que crezca hacia arriba si hace falta.
	panel.anchor_left = 0.0
	panel.anchor_right = 1.0
	panel.anchor_top = 1.0
	panel.anchor_bottom = 1.0
	panel.offset_left = 40.0
	panel.offset_right = -40.0
	panel.offset_top = -200.0
	panel.offset_bottom = -30.0
	panel.grow_vertical = Control.GROW_DIRECTION_BEGIN

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.05, 0.06, 0.1, 0.92)
	style.border_color = Color(0.85, 0.85, 0.95, 0.9)
	style.set_border_width_all(2)
	style.set_corner_radius_all(8)
	style.set_content_margin_all(20.0)
	panel.add_theme_stylebox_override("panel", style)

	var box := VBoxContainer.new()
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_theme_constant_override("separation", 8)
	panel.add_child(box)

	_name_label = Label.new()
	_name_label.add_theme_font_size_override("font_size", 24)
	_name_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.4))
	box.add_child(_name_label)

	_text_label = Label.new()
	_text_label.add_theme_font_size_override("font_size", 26)
	_text_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_text_label.custom_minimum_size = Vector2(0, 80)
	_text_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.add_child(_text_label)

	_hint_label = Label.new()
	_hint_label.add_theme_font_size_override("font_size", 18)
	_hint_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.8))
	_hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	box.add_child(_hint_label)
