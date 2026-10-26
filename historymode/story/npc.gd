class_name Npc
extends StaticBody2D
## Personaje (o letrero) con el que se habla pulsando E cuando estás cerca.
## Se dibuja con una hoja de sprites (ver character_sprite.gd).
## Se configura en el Inspector:
##   display_name    - nombre que aparece sobre el personaje
##   first_dialogue  - id del diálogo (ver story.gd) la primera vez
##   repeat_dialogue - id del diálogo que se repite después (vacío = repite el primero)
##   is_sign         - true = se usa la imagen del letrero en lugar de una persona
##   sprite_sheet    - imagen del personaje (vacío = la de Mara). Con columnas = fotogramas
##                     y filas = direcciones (abajo, izquierda, derecha, arriba)
##   sheet_columns / sheet_rows - tamaño de la cuadrícula de esa imagen
##   facing          - hacia dónde mira cuando está quieto
##   sprite_tint     - color que se multiplica a la imagen (blanco = sin cambios)

const SIGN_SHEET := preload("res://assets/sprites/sign.png")

@export var display_name: String = "Mara"
@export var first_dialogue: String = "mara_first"
@export var repeat_dialogue: String = ""
@export var is_sign: bool = false

@export_group("Apariencia")
@export var sprite_sheet: Texture2D
@export var sheet_columns: int = 4
@export var sheet_rows: int = 4
@export_enum("Abajo", "Izquierda", "Derecha", "Arriba") var facing: int = 0
@export var sprite_tint: Color = Color.WHITE

@onready var _name_label: Label = $NameLabel
@onready var _prompt: Label = $Prompt
@onready var _talk_area: Area2D = $InteractArea
@onready var _sprite: CharacterSprite = $Sprite

var _player_near: bool = false


func _ready() -> void:
	add_to_group("npcs")
	_name_label.text = display_name
	_prompt.hide()
	_talk_area.body_entered.connect(_on_body_entered)
	_talk_area.body_exited.connect(_on_body_exited)
	_setup_sprite()


func _setup_sprite() -> void:
	if is_sign:
		# El letrero es una sola imagen, sin cuadrícula ni direcciones.
		_sprite.texture = SIGN_SHEET
		_sprite.hframes = 1
		_sprite.vframes = 1
	elif sprite_sheet != null:
		_sprite.texture = sprite_sheet
		_sprite.hframes = maxi(sheet_columns, 1)
		_sprite.vframes = maxi(sheet_rows, 1)

	_sprite.self_modulate = sprite_tint
	_sprite.set_facing(facing)


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
