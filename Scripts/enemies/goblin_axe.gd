extends Enemy
class_name Goblin_axe

func _ready() -> void:
	super._ready()
	
	life = 3
	speed = 110
	damage = 1
	num_attacks = 2
	max_parry_resistance = 1
	dist_mellee = 25
	should_jump = true
