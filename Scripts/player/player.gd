extends CharacterBody2D
class_name Player

@onready var animation: AnimationPlayer = $body/Animacoes
@onready var dash_cooldown: Timer = $dash_cooldown
@onready var invencible_timer: Timer = $invincible_timer
@onready var sprite: Sprite2D = $body/sprite

@export var speed: int = 300
@export var jump: int = -300
@export var jump_horizontal = 100
@export var max_hp : int = 30

const gravity = 1000
const dash_speed := 280
var current_hp: int
var dash_duration := 0.30
var direction = 0
var is_attacking = false
var can_dash := true
var is_dashing := false
var dash_timer := 0.0
var is_invincible := false
var damage_amount : int = 2
var already_hit_enemies = []

enum states {idle, run, jump, dash, death, attack_1,attack_2,hurt}

var current_state: states

func _ready():
	current_state = states.idle
	current_hp = max_hp
	dash_duration = animation.get_animation("dash").length

func _physics_process(delta: float):
 
	if current_state == states.hurt:
		player_falling(delta)
		move_and_slide()
		player_animations()
		return

	player_movements()
	player_falling(delta)
	player_idle(delta)
	player_dash(delta)
	player_run(delta)
	player_jump(delta)
	player_attack(delta)

	move_and_slide()
	player_animations()

	
func player_falling(delta: float):
	if !is_on_floor():
		velocity.y += gravity * delta
		
func player_idle(delta: float):
	if current_state == states.hurt:
		return
	if is_attacking or is_dashing:
		return
	if is_on_floor() and direction == 0:
		current_state = states.idle

func player_run(delta: float):
	if current_state == states.hurt:
		return
	if is_attacking or is_dashing:
		return
	if !is_on_floor():
		return
		
	if direction != 0:
		current_state = states.run
		
func player_jump(delta: float):
	if current_state == states.hurt:
		return
	if is_attacking or is_dashing:
		return
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump
		current_state = states.jump
	if !is_on_floor() and current_state == states.jump:
		velocity.x += direction * jump_horizontal * delta
		
func player_attack(delta):
	if current_state == states.hurt:
		return
	if is_dashing:
		return
	if Input.is_action_just_pressed("attack") and !is_attacking:
		is_attacking = true
		if is_on_floor():
			velocity.x = 0 
		current_state = states.attack_1
		
func player_dash(delta):
	if current_state == states.hurt:
		return
	if Input.is_action_just_pressed("dash") and direction != 0 and can_dash == true and !is_attacking:
		is_dashing = true
		dash_timer = dash_duration
		
	if is_dashing:
		dash(delta) 
		dash_timer -= delta 
		if dash_timer <= 0: 
			is_dashing = false 
			is_invincible = false 
			velocity.x = 0

func dash(delta):
	velocity.x = direction * dash_speed 
	can_dash = false 
	is_invincible = true 
	current_state = states.dash
	dash_cooldown.start() 

func player_animations():
	if current_state == states.hurt:
		if animation.current_animation != "hurt":
			animation.play("hurt")
		return
		
	match current_state:
		states.idle:
			if animation.current_animation != "idle":
				animation.play("idle")
		states.run:
			if animation.current_animation != "run":
				animation.play("run")
		states.dash:
			if animation.current_animation != "dash":
				animation.play("dash")
		states.attack_1:
			if animation.current_animation != "attack_1":
				animation.play("attack_1")
		states.attack_2:
			if animation.current_animation != "attack_2":
				animation.play("attack_2")
		states.jump:
			if animation.current_animation != "jump":
				animation.play("jump")
		states.hurt:
			if animation.current_animation != "hurt":
				animation.play("hurt")

		
func player_movements():
	if current_state == states.hurt:
		return
	if is_dashing:
		return
	if is_attacking and is_on_floor():
		velocity.x = 0
		return
	
	direction = Input.get_axis("move_left","move_right")
	
	if direction:
		velocity.x = direction * speed
		$body.scale.x = -1 if direction < 0 else 1
	else:
		velocity.x = move_toward(velocity.x, 0, speed)

func _on_animacoes_animation_finished(anim_name: StringName):
	if anim_name == "attack_1":
		is_attacking = false 
		already_hit_enemies.clear() 
	if anim_name == "hurt":
		current_state = states.idle

func _on_hitbox_body_entered(body):
	if body.is_in_group("enemies") and body.has_method("take_damage"):
		if body in already_hit_enemies:
			return 
		body.take_damage(damage_amount)
		already_hit_enemies.append(body)

func get_damage_amount() -> int:
	return damage_amount
		
func take_damage(amount: int, hit_position: Vector2):
	if is_invincible or current_state == states.death:
		return
	
	current_hp -= amount
	
	flash_white()

	if current_hp > 0:
		if current_state != states.attack_1 and current_state != states.attack_2:
			current_state = states.hurt
			is_dashing = false
			velocity.x = 0
			animation.play("hurt")
	else:
		die()

func die():
	current_state = states.death
	velocity = Vector2.ZERO
	animation.play("death")
	set_physics_process(false) 
	
	await animation.animation_finished
	GameManager.return_to_menu()

func flash_white():
	sprite.modulate = Color(3, 3, 3) 
	var tween := create_tween()
	tween.tween_property(sprite, "modulate", Color(1, 1, 1), 0.1)

func _on_dash_cooldown_timeout():
	can_dash = true

func _on_invincible_timer_timeout():
	is_invincible = false
