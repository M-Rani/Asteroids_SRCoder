extends Asteroid
class_name Rock

signal rock_destroyed

func _on_Area2D_area_entered(area: Area2D) -> void:
	if area is Bullet:
		emit_signal("rock_destroyed")
		area.queue_free()
		queue_free()
