extends CanvasLayer

var t = 0
var frequency = 50
var magnitude = 0
var x_start = 0
var y_start = 0

func _process(delta):
	t += delta
	magnitude =  lerp(magnitude, 0, delta * 15)
	offset.x = sin(t*frequency+x_start) * magnitude / 4
	offset.y = sin(t*frequency+y_start) * magnitude / 4
	$score_label.set_position(Vector2([-magnitude/25,magnitude/25][randi() % 2], 20 + [-magnitude/25,magnitude/25][randi() % 2]))

func shake(strength:float = 1.0):
	randomize()
	x_start = rand_range(0,2*PI)
	y_start = rand_range(0,2*PI)
	magnitude = [-25,25][randi() % 2] * strength
