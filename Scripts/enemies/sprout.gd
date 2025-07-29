class_name Sprout
extends Enemy

func _ready() -> void:
	super._ready()
	
	life = 6
	speed = 90
	damage = 2
	max_parry_resistance = 2
	dist_mellee = 35
	should_jump = true
