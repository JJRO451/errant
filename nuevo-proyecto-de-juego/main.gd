extends Node2D

var score: int = 0
var total_coins: int = 0
var finished: bool = false

var pause_menu: PauseMenu

@onready var score_label: Label = $ScoreLabel


func _ready() -> void:
	# Menú de pausa / victoria (se construye por código, ver pause_menu.gd).
	pause_menu = PauseMenu.new()
	add_child(pause_menu)

	var coins = get_tree().get_nodes_in_group("coins")
	total_coins = coins.size()

	for coin in coins:
		coin.connect("collected", _on_coin_collected)

	score_label.text = "Monedas: 0 / %d" % total_coins


func _unhandled_input(event: InputEvent) -> void:
	# Esc (o B del mando) abre la pausa.
	if event.is_action_pressed("ui_cancel") and not finished and not pause_menu.is_open():
		pause_menu.open("Pausa", true)
		get_viewport().set_input_as_handled()


func _on_coin_collected() -> void:
	score += 1

	if score >= total_coins:
		finished = true
		score_label.text = "¡GANASTE!"
		# Pausa el juego (el jugador deja de moverse) y muestra las opciones.
		pause_menu.open("¡Ganaste!", false, "Jugar de nuevo")
	else:
		score_label.text = "Monedas: %d / %d" % [
			score,
			total_coins
		]
