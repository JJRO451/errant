class_name CharacterArt
extends RefCounted
## Dibuja un personaje sencillo con código, para no depender de imágenes.
## Se usa dentro del _draw() de un nodo:  CharacterArt.draw(self, Color.RED)
## El punto (0, 0) es el centro del cuerpo; los pies quedan en y = 38.


static func draw(
	item: CanvasItem,
	shirt: Color,
	hair: Color = Color(0.25, 0.15, 0.1),
	skin: Color = Color(0.96, 0.8, 0.65)
) -> void:
	var dark := Color(0.15, 0.12, 0.12)
	var pants := Color(0.2, 0.25, 0.45)

	# Sombra en el suelo (un círculo aplastado).
	item.draw_set_transform(Vector2(0, 38), 0.0, Vector2(1.0, 0.3))
	item.draw_circle(Vector2.ZERO, 22.0, Color(0, 0, 0, 0.25))
	item.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

	# Piernas.
	item.draw_rect(Rect2(-12, 24, 10, 14), pants)
	item.draw_rect(Rect2(2, 24, 10, 14), pants)

	# Cuerpo (camisa) y brazos.
	item.draw_rect(Rect2(-16, -4, 32, 32), shirt)
	item.draw_rect(Rect2(-22, -2, 7, 22), shirt.darkened(0.15))
	item.draw_rect(Rect2(15, -2, 7, 22), shirt.darkened(0.15))

	# Manos.
	item.draw_circle(Vector2(-18.5, 22), 4.0, skin)
	item.draw_circle(Vector2(18.5, 22), 4.0, skin)

	# Cabeza: primero el pelo y encima la cara.
	item.draw_circle(Vector2(0, -23), 19.0, hair)
	item.draw_circle(Vector2(0, -18), 16.0, skin)

	# Cara: ojos y sonrisa.
	item.draw_circle(Vector2(-6, -18), 2.5, dark)
	item.draw_circle(Vector2(6, -18), 2.5, dark)
	item.draw_arc(Vector2(0, -13), 6.0, 0.3, PI - 0.3, 10, dark, 1.5)
