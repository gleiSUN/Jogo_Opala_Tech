extends CharacterBody2D

@onready var Animacoes = $body/Animacoes

const gravity = 1000
@export var speed: int = 300
@export var jump: int = -300
@export var jump_horizontal = 100

var direction = 0

enum states {idle, run, jump, dash, death}

var current_state: states

func _ready():
	current_state = states.idle
	
func _physics_process(delta: float):
	player_movements()
	player_falling(delta)
	player_idle(delta)
	player_run(delta)
	player_jump(delta)
	
	move_and_slide()
	
	player_animations()
	
func player_falling(delta: float):
	if !is_on_floor():
		velocity.y += gravity * delta
		
func player_idle(delta: float):
	if is_on_floor():
		current_state = states.idle

func player_run(delta: float):
	if !is_on_floor():
		return
		
	if direction != 0:
		current_state = states.run
		
func player_jump(delta: float):
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump
		current_state = states.jump
	if !is_on_floor() and current_state == states.jump:
		velocity.x += direction * jump_horizontal * delta
		
func player_animations():
	if current_state == states.idle:
		Animacoes.play("idle")
	elif current_state == states.run:
		Animacoes.play("run")
	elif current_state == states.jump:
		Animacoes.play("jump")
		
func player_movements():
	direction = Input.get_axis("move_left","move_right")
	
	if direction:
		velocity.x = direction * speed
		$body.scale.x = -1 if direction < 0 else 1
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
