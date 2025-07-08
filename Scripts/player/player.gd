extends CharacterBody2D

@onready var animation: AnimationPlayer = $body/Animacoes

const gravity = 1000
@export var speed: int = 300
@export var jump: int = -300
@export var jump_horizontal = 100

var direction = 0
var is_attacking = false

enum states {idle, run, jump, dash, death, attack_1,attack_2}

var current_state: states

func _ready():
	current_state = states.idle
	
func _physics_process(delta: float):
	player_movements()
	player_falling(delta)
	player_idle(delta)
	player_run(delta)
	player_jump(delta)
	player_attack(delta)
	
	move_and_slide()
	
	player_animations()
	
func player_falling(delta: float):
	if !is_on_floor():
		velocity.y += gravity * delta
		
func player_idle(delta: float):
	if is_attacking:
		return
	if is_on_floor() and direction == 0:
		current_state = states.idle

func player_run(delta: float):
	if is_attacking:
		return
	if !is_on_floor():
		return
		
	if direction != 0:
		current_state = states.run
		
func player_jump(delta: float):
	if is_attacking:
		return
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump
		current_state = states.jump
	if !is_on_floor() and current_state == states.jump:
		velocity.x += direction * jump_horizontal * delta
		
func player_attack(delta):
	if Input.is_action_just_pressed("attack") and !is_attacking:
		is_attacking = true
		if is_on_floor():
			velocity.x = 0 
		current_state = states.attack_1
		
func player_animations():
	if current_state == states.idle:
		animation.play("idle")
	elif current_state == states.run:
		animation.play("run")
	elif current_state == states.attack_1:
		animation.play("attack_1")
	elif current_state == states.attack_1:
		animation.play("attack_2")
	elif current_state == states.jump:
		animation.play("jump")
		
func player_movements():
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
