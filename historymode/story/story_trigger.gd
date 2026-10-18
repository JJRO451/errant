class_name StoryTrigger
extends Area2D
## Zona invisible que lanza un diálogo cuando el jugador entra.
## Ponla en la escena como un Area2D con este script (no necesita nada más):
##   dialogue_id  - id del diálogo (ver story.gd)
##   size         - tamaño de la zona
##   once         - si es true, solo se dispara la primera vez
##   skip_if_flag - si esta bandera ya está activa, no se dispara
##                  (ejemplo: "done_mara_first")

@export var dialogue_id: String = ""
@export var size: Vector2 = Vector2(200, 200)
@export var once: bool = true
@export var skip_if_flag: String = ""


func _ready() -> void:
	# Solo detecta, no es detectada por nadie.
	collision_layer = 0
	monitorable = false

	var shape := RectangleShape2D.new()
	shape.size = size
	var collision := CollisionShape2D.new()
	collision.shape = shape
	add_child(collision)

	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if not (body is Player):
		return
	if once and Story.has_flag("done_" + dialogue_id):
		return
	if skip_if_flag != "" and Story.has_flag(skip_if_flag):
		return

	var dialogue := get_tree().get_first_node_in_group("dialogue_box") as DialogueBox
	if dialogue != null:
		dialogue.play(dialogue_id)
