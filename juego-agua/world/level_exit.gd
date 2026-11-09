@tool
class_name LevelExit
extends Area2D
## Salida que lleva a otro escenario cuando el jugador la cruza.
## Colócala en el borde del mapa (o en una puerta) y configúrala en el Inspector:
##   target_scene   - escenario al que viaja (elige el archivo .tscn)
##   spawn_id       - id del LevelSpawn de ese escenario donde aparecerás
##   label          - texto que se ve junto a la salida (por ejemplo "Bosque →")
##   size / color   - tamaño y color de la zona
##   required_flag  - (opcional) bandera de la historia necesaria para pasar
##   locked_dialogue- (opcional) diálogo que sale si aún no se cumple (ver story.gd)

@export_file("*.tscn") var target_scene: String = ""
@export var spawn_id: String = ""
@export var label: String = "":
	set(value):
		label = value
		queue_redraw()
@export var size: Vector2 = Vector2(80, 260):
	set(value):
		size = value
		_refresh()
@export var color: Color = Color(1.0, 0.9, 0.5, 0.3):
	set(value):
		color = value
		queue_redraw()
## Dónde se escribe el texto, respecto al centro de la salida.
@export var label_offset: Vector2 = Vector2(0, -150):
	set(value):
		label_offset = value
		queue_redraw()

@export_group("Condición")
@export var required_flag: String = ""
@export var locked_dialogue: String = ""

var _used: bool = false


func _ready() -> void:
	_refresh()
	if Engine.is_editor_hint():
		return

	# Solo detecta al jugador; nadie la detecta a ella.
	collision_layer = 0
	monitorable = false
	body_entered.connect(_on_body_entered)


func _refresh() -> void:
	queue_redraw()
	if not is_inside_tree():
		return

	var shape_node := get_node_or_null("AutoCollision") as CollisionShape2D
	if shape_node == null:
		shape_node = CollisionShape2D.new()
		shape_node.name = "AutoCollision"
		shape_node.shape = RectangleShape2D.new()
		add_child(shape_node)
	(shape_node.shape as RectangleShape2D).size = size


func _draw() -> void:
	var rect := Rect2(-size / 2.0, size)
	draw_rect(rect, color)
	draw_rect(rect, Color(color, minf(color.a + 0.4, 1.0)), false, 3.0)

	if label != "":
		var font := ThemeDB.fallback_font
		var pos := label_offset + Vector2(-150, 0)
		draw_string_outline(font, pos, label, HORIZONTAL_ALIGNMENT_CENTER, 300, 24, 6, Color.BLACK)
		draw_string(font, pos, label, HORIZONTAL_ALIGNMENT_CENTER, 300, 24, Color(1, 0.95, 0.7))


func _on_body_entered(body: Node2D) -> void:
	if _used or not (body is Player):
		return

	if required_flag != "" and not Story.has_flag(required_flag):
		var dialogue := get_tree().get_first_node_in_group("dialogue_box") as DialogueBox
		if dialogue != null and locked_dialogue != "":
			dialogue.play(locked_dialogue)
		return

	if target_scene == "":
		push_warning("LevelExit '%s': falta elegir 'target_scene' en el Inspector." % name)
		return

	var level := get_tree().get_first_node_in_group("level") as Level
	if level == null:
		return

	_used = true
	level.travel_to(target_scene, spawn_id)
