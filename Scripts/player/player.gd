extends CharacterBody2D

@onready var animation: AnimationPlayer = $body/Animacoes
@onready var dash_cooldown: Timer = $dash_cooldown
@onready var invencible_timer: Timer = $invincible_timer

@export var speed: int = 300
@export var jump: int = -300
@export var jump_horizontal = 100

const gravity = 1000
const dash_speed := 270
var dash_duration := 0.15
var direction = 0
var is_attacking = false
var can_dash := true
var is_dashing := false
var dash_timer := 0.0
var is_invincible := false

enum states {idle, run, jump, dash, death, attack_1,attack_2}

var current_state: states

func _ready():
	current_state = states.idle
	dash_duration = animation.get_animation("dash").length

func _physics_process(delta: float):
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
	if is_attacking or is_dashing:
		return
	if is_on_floor() and direction == 0:
		current_state = states.idle

func player_run(delta: float):
	if is_attacking or is_dashing:
		return
	if !is_on_floor():
		return
		
	if direction != 0:
		current_state = states.run
		
func player_jump(delta: float):
	if is_attacking or is_dashing:
		return
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump
		current_state = states.jump
	if !is_on_floor() and current_state == states.jump:
		velocity.x += direction * jump_horizontal * delta
		
func player_attack(delta):
	if is_dashing:
		return
	if Input.is_action_just_pressed("attack") and !is_attacking:
		is_attacking = true
		if is_on_floor():
			velocity.x = 0 
		current_state = states.attack_1
		
func player_dash(delta):
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


		
func player_movements():
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
		
func _on_hitbox_body_entered(body):
	if body.is_in_group("enemies"):
		print(body.name)
		body.queue_free()

func _on_dash_cooldown_timeout():
	can_dash = true

#func _on_invincible_timer_timeout():
	
