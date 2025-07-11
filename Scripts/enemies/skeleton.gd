extends CharacterBody2D

@onready var animation: AnimationPlayer = $body/animacoes
@onready var timer: Timer = $Timer
@onready var attack_area: Area2D = $body/attack_area
@onready var attack_cooldown: Timer = $attack_cooldown
@onready var sprite: Sprite2D = $body/sprite

@export var patrol_points: Node
@export var speed: int = 1500
@export var wait_time : int = 3

const gravity = 1000
var direction = Vector2.LEFT
enum state{idle, run, hurt, attack,death, react}
var is_attacking : bool = false
var player_detected: bool = false
var current_state : state
var number_of_points : int
var points_positions : Array[Vector2]
var current_point: Vector2
var current_point_position: int
var can_walk : bool
@export var max_hp: int = 6
@export var damage_amount: int = 2
var current_hp: int

func _ready():
	current_hp = max_hp

	if patrol_points != null:
		number_of_points = patrol_points.get_children().size()
		for point in patrol_points.get_children():
			points_positions.append(point.global_position)
		current_point = points_positions[current_point_position]
	else:
		print("no patrol points")
		
	if current_point.x > position.x:
		direction = Vector2.RIGHT
	else:
		direction = Vector2.LEFT

	$body.scale.x = 1 if direction.x > 0 else -1
	
	timer.wait_time = wait_time

	current_state = state.idle

func _physics_process(delta: float):
	match current_state:
		state.hurt, state.death, state.attack:
			velocity.x = move_toward(velocity.x, 0, speed * delta)
			move_and_slide()
			enemy_animations()
			return
			
	if player_detected and !is_attacking and current_state != state.hurt and current_state != state.death and current_state != state.attack and attack_cooldown.time_left == 0:
		start_attack()
		return

	enemy_gravity(delta)
	enemy_idle(delta)
	enemy_run(delta)
	move_and_slide()
	enemy_animations()
	
func enemy_gravity(delta):
	velocity.y += gravity * delta
	
func enemy_idle(delta):
	if !can_walk:
		velocity.x = move_toward(velocity.x,0,speed * delta)
		current_state = state.idle
	
func enemy_run(delta):
	if !can_walk:
		return
		
	if abs(position.x - current_point.x) > 0.5:
		velocity.x = direction.x * speed * delta
		current_state = state.run
		
		$body.scale.x = 1 if direction.x > 0 else -1
	else:
		current_point_position += 1
		
		if current_point_position >= number_of_points:
			current_point_position = 0
		
		current_point = points_positions[current_point_position];
		
		if current_point.x > position.x:
			direction = Vector2.RIGHT
		else:
			direction = Vector2.LEFT
			
		can_walk = false
		timer.start()
		
func start_attack():
	if attack_cooldown.time_left > 0:
		return # em cooldown, não ataca ainda

	if not is_instance_valid(get_tree().get_first_node_in_group("player")):
		return

	var player = get_tree().get_first_node_in_group("player")
	if player.global_position.x > global_position.x:
		direction = Vector2.RIGHT
	else:
		direction = Vector2.LEFT

	$body.scale.x = 1 if direction.x > 0 else -1

	current_state = state.attack
	is_attacking = true
	velocity.x = 0
	attack_area.monitoring = true
	animation.play("attack")
	print("inimigo atacando")

func enemy_animations():
	match current_state:
		state.idle:
			animation.play("idle")
		state.run:
			animation.play("run")
		state.hurt:
			if animation.current_animation != "hurt":
				animation.play("hurt")
		state.attack:
			if animation.current_animation != "attack":
				animation.play("attack")
		state.death:
			if animation.current_animation != "death":
				animation.play("death")
	
func _on_timer_timeout():
	can_walk = true

func get_damage_amount() -> int:
	return damage_amount
	
func take_damage(amount: int, hit_position: Vector2):
	if current_state == state.death:
		return

	print("tomou dano")
	current_hp -= amount
	
	flash_white()
	
	if current_hp <= 0:
		die()
	else:
		if current_state != state.attack:
			current_state = state.hurt
			animation.play("hurt")
			velocity = Vector2.ZERO
			can_walk = false
			timer.start()


func die():
	current_state = state.death
	animation.play("death")
	velocity = Vector2.ZERO
	set_physics_process(false)
	await animation.animation_finished
	queue_free()
	
func flash_white():
	sprite.modulate = Color(3, 3, 3) 
	var tween := create_tween()
	tween.tween_property(sprite, "modulate", Color(1, 1, 1), 0.1)

func _on_animacoes_animation_finished(anim_name: StringName) -> void:
	if anim_name == "hurt" and current_state == state.hurt:
		current_state = state.idle

	elif anim_name == "attack" and current_state == state.attack:
		is_attacking = false
		attack_area.monitoring = false
		attack_cooldown.start()  # começa cooldown após o ataque

		if player_detected:
			current_state = state.idle
		else:
			can_walk = true
			current_state = state.idle
			
func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_detected = true
		can_walk = false
		
func _on_detection_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_detected = false
		can_walk = true

func _on_attack_area_body_entered(body):
	if current_state == state.attack and body.is_in_group("player") and body.has_method("take_damage"):
		body.take_damage(damage_amount, global_position)
		print("aplicando dano ao player")
