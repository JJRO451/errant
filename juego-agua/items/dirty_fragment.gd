class_name DirtyFragment
extends Area2D
## Fragmento gris (agua contaminada). Es la trampa educativa: tocarlo cuenta como
## un error, quita una vida y explica el mito o mal hábito que representa.
## No cuenta como fragmento para ganar (no está en el grupo "coins").
##   myth_id - id del mito en story.gd (los que empiezan con "mito_"). Se explica
##             solo la primera vez; las siguientes solo hay daño.


@export var myth_id: String = ""


func _ready() -> void:
	add_to_group("dirty_fragments")
	body_entered.connect(_on_body_entered)

	# Pulso lento y apagado, para que se distinga del latido dorado.
	var tween := create_tween().set_loops()
	tween.tween_property(self, "modulate:a", 0.55, 0.9)
	tween.tween_property(self, "modulate:a", 1.0, 0.9)


func _on_body_entered(body: Node2D) -> void:
	var player := body as Player
	if player == null:
		return

	var level := get_tree().get_first_node_in_group("level") as Level
	if level != null:
		level.register_error()

	Effects.burst(get_parent(), global_position, Color(0.45, 0.35, 0.2), 18, 160.0)
	player.take_damage(1, global_position)

	# Si el golpe fue mortal, el Game Over manda; si no, se explica el mito.
	if player.health > 0 and myth_id != "" and not Story.has_flag("done_" + myth_id):
		var dialogue := get_tree().get_first_node_in_group("dialogue_box") as DialogueBox
		if dialogue != null and not dialogue.is_open():
			dialogue.play(myth_id)

	queue_free()
