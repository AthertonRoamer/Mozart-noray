class_name HealthDisplayBar
extends HealthDisplay

var max_health : int = 5

func update_health_bar() -> void:
	$TextureProgressBar.max_value = max_health

func set_health(n : int):
	health = n
	$TextureProgressBar.value = n
