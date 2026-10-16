extends Node2D

var score: int = 0
var total_coins: int = 0

@onready var score_label: Label = $ScoreLabel
@onready var restart_button: Button = $RestartButton

func _ready() -> void:
	restart_button.visible = false
	restart_button.text = "Jugar de nuevo"
	restart_button.size = Vector2(180, 50)

	var screen_size = get_viewport_rect().size
	restart_button.position = (screen_size - restart_button.size) / 2.0

	restart_button.pressed.connect(_on_restart_pressed)

	var coins = get_tree().get_nodes_in_group("coins")
	total_coins = coins.size()

	for coin in coins:
		coin.connect("collected", _on_coin_collected)

	score_label.text = "Monedas: 0 / %d" % total_coins


func _on_coin_collected() -> void:
	score += 1

	if score >= total_coins:
		score_label.text = "¡GANASTE!"
		restart_button.visible = true
	else:
		score_label.text = "Monedas: %d / %d" % [
			score,
			total_coins
		]


func _on_restart_pressed() -> void:
	get_tree().reload_current_scene()
