extends Area2D
class_name Bullet

export (float) var speed = 500

func _process(delta):
	# Move the bullet
	position += transform.x * speed * delta

func _on_Timer_timeout():
	queue_free()
