class_name Golem_blue
extends Enemy

func _ready() -> void:
	super._ready()
	
	life = 8
	speed = 60
	damage = 2
	max_parry_resistance = 3
	dist_mellee = 40
	should_jump = false
