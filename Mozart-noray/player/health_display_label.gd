extends HealthDisplay

func set_health(n : int):
	health = n
	$Label.text = str(health)
