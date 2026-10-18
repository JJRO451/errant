class_name StoryGate
extends StaticBody2D
## Barrera que bloquea el paso hasta que cierta bandera de la historia se activa.
## Ejemplo: required_flag = "done_mara_first" -> se abre al hablar con Mara.
## Cámbiale el tamaño con "scale" y el color con "modulate" en el Inspector.

@export var required_flag: String = "done_mara_first"

@onready var _shape: CollisionShape2D = $CollisionShape2D

var _opened: bool = false


func _ready() -> void:
	add_to_group("story_listeners")
	on_story_changed()


## Lo llama el diálogo al terminar (grupo "story_listeners").
func on_story_changed() -> void:
	if _opened or not Story.has_flag(required_flag):
		return

	_opened = true
	_shape.set_deferred("disabled", true)

	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.6)
	tween.tween_callback(queue_free)
