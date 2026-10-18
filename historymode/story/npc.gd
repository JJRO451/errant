class_name Npc
extends StaticBody2D
## Personaje (o letrero) con el que se habla pulsando E cuando estás cerca.
## Se dibuja con código (CharacterArt), no necesita imágenes.
## Se configura en el Inspector:
##   display_name    - nombre que aparece sobre el personaje
##   first_dialogue  - id del diálogo (ver story.gd) la primera vez
##   repeat_dialogue - id del diálogo que se repite después (vacío = repite el primero)
##   is_sign         - true = se dibuja como un letrero en lugar de una persona
##   body_color      - color de la camisa (o del tablero del letrero)
##   hair_color      - color del pelo

@export var display_name: String = "Mara"
@export var first_dialogue: String = "mara_first"
@export var repeat_dialogue: String = ""
@export var is_sign: bool = false
@export var body_color: Color = Color(0.85, 0.45, 0.55)
@export var hair_color: Color = Color(0.85, 0.85, 0.88)

@onready var _name_label: Label = $NameLabel
@onready var _prompt: Label = $Prompt
@onready var _talk_area: Area2D = $InteractArea

var _player_near: bool = false


func _ready() -> void:
	add_to_group("npcs")
	_name_label.text = display_name
	_prompt.hide()
	_talk_area.body_entered.connect(_on_body_entered)
	_talk_area.body_exited.connect(_on_body_exited)


func _draw() -> void:
	if is_sign:
		_draw_sign()
	else:
		CharacterArt.draw(self, body_color, hair_color)


func _draw_sign() -> void:
	# Sombra, poste y tablero.
	draw_set_transform(Vector2(0, 38), 0.0, Vector2(1.0, 0.3))
	draw_circle(Vector2.ZERO, 22.0, Color(0, 0, 0, 0.25))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	draw_rect(Rect2(-4, -10, 8, 48), Color(0.4, 0.27, 0.15))
	draw_rect(Rect2(-34, -40, 68, 36), body_color)
	draw_rect(Rect2(-34, -40, 68, 36), body_color.darkened(0.4), false, 3.0)


func _unhandled_input(event: InputEvent) -> void:
	if not _player_near or not event.is_action_pressed("interact"):
		return

	var dialogue := get_tree().get_first_node_in_group("dialogue_box") as DialogueBox
	if dialogue == null or dialogue.is_open():
		return

	get_viewport().set_input_as_handled()
	dialogue.play(_current_dialogue_id())


func _current_dialogue_id() -> String:
	if repeat_dialogue != "" and Story.has_flag("done_" + first_dialogue):
		return repeat_dialogue
	return first_dialogue


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		_player_near = true
		_prompt.show()


func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		_player_near = false
		_prompt.hide()
