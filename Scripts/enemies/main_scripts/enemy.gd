class_name Enemy
extends CharacterBody2D

@onready var player = Utils.get_player()
@onready var animation: AnimationPlayer = $body/animation
@onready var body: Node2D = $body
@onready var sprite: Sprite2D = $body/sprite
@onready var collision: CollisionShape2D = $collision

var type_patrol := false
var type_follower := false

var speed := 100
var jump_height := -130
var dist_follow := 280
var dist_mellee := 35
var dist_range_attack := 200
var dist_spawn := 50

var damage := 1
var life := 3
var max_parry_resistance := 2
var parry_resistance := 0
var num_attacks := 1
var num_range_attacks := 1

var distance
var direction := -1
var should_jump := true
var flip_compensation := 0
var position_compensation := 0

var can_jump := false
var is_stuned := false
var has_parried := false
var is_dead := false
var is_damaged := false
var is_attacking := false
var is_range_attacking := false
var is_following := false
var has_spawned := true
var is_spawning := false

var current_attack := 1
var current_range_attack := 1
var current_state := "idle"

func _ready():
	randomize()

func _physics_process(delta: float) -> void:
	update_logic(delta)
	set_state()
	move_and_slide()

func update_logic(delta: float):
	if parry_resistance <= 0:
		parry_resistance = max_parry_resistance
	
	if is_dead:
		velocity.x = 0
		remove_from_group("enemies")
		return
	
	if !is_on_floor():
		velocity += get_gravity() * delta

	if is_following and can_jump:
		velocity.y = jump_height
	
	velocity.x = direction * speed if is_following or type_patrol else 0

	if is_attacking:
		velocity.x = 0
		if !animation.is_playing():
			is_attacking = false
			current_attack = randi_range(1, num_attacks)

	if is_range_attacking:
		velocity.x = 0
		if !animation.is_playing():
			is_range_attacking = false
			current_range_attack = randi_range(1, num_range_attacks)

	if is_damaged:
		velocity.x = 0
		if !has_spawned:
			is_spawning = true
		
		if !animation.is_playing():
			is_damaged = false

# controla as animaçoes
func set_state():
	var new_state = "idle"

	if is_dead:
		new_state = "die"
	elif is_damaged and !is_attacking and !is_range_attacking and has_spawned:
		new_state = "hurt"
	elif has_parried:
		new_state = "parried"
	elif is_stuned:
		new_state = "idle"
	elif is_attacking:
		new_state = "attack_" + str(current_attack)
	elif is_range_attacking:
		new_state = "range_attack_" + str(current_range_attack)
	elif velocity.x != 0:
		new_state = "walk"
	elif is_spawning:
		new_state = "spawn"

	if current_state != new_state:
		animation.play(new_state)
		current_state = new_state

# faz o mob receber dano
func take_damage(dmg: int):
	if Mobs.apply_damage(self, dmg):
		Mobs.hit_blink(sprite)

# gira o mob
func flip_sprite():
	# giro para o tipo que apenas anda de um lado para o outro
	if type_patrol:
		direction *= -1
	
	# giro para o tipo perseguidor
	if type_follower:
		direction = 1 if global_position.x < player.global_position.x else -1
	
	# compensa a diferença da colisao (quando ao girar, a colisao sai do mob)
	if flip_compensation != 0:
		collision.position.x = direction * (flip_compensation + position_compensation)
	
	# compensa a diferença de sprites, para suavisar o giro de sprites muito largos
	if position_compensation != 0:
		body.position.x = direction * position_compensation

	body.scale.x = direction

# controla certas flags com base no fim da animaçao
func _on_animation_animation_finished(anim_name: StringName) -> void:
	if anim_name == "die":
		queue_free()
		
	# controla se o mob ja foi ativado ou nao
	elif anim_name == "spawn":
		is_spawning = false
		has_spawned = true

	# diminue a resistencia aos parrys
	elif anim_name == "parried" and has_parried:
		has_parried = false
		parry_resistance -= 1
		
		# fica stunado
		if parry_resistance <= 0:
			Mobs.take_stun(self)
