extends CharacterBody2D

@onready var Animacoes = $body/Animacoes

const gravity = 1000
const speed = 300
const jump = -300
const jump_horizontal = 100
var direction = 0

enum states {idle, run, jump, dash, death}

var current_state

func _ready():
	current_state = states.idle
	
func _physics_process(delta):
	player_falling(delta)
	player_idle(delta)
	player_run(delta)
	player_jump(delta)
	
	move_and_slide()
	
	player_animations()
	
func player_falling(delta):
	if !is_on_floor():
		velocity.y += gravity * delta
		
func player_idle(delta):
	if is_on_floor():
		current_state = states.idle

func player_run(delta):
	if !is_on_floor():
		return
		
	direction = Input.get_axis("move_left","move_right")
	
	if direction:
		velocity.x = direction * speed
	else:
		velocity.x = move_toward(velocity.x,0,speed)
		
	if direction != 0:
		current_state = states.run
		Animacoes.flip_h = false if direction > 0 else true
		
func player_jump(delta):
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump
		current_state = states.jump
	if !is_on_floor() and current_state == states.jump:
		direction = Input.get_axis("move_left","move_right")
		velocity.x += direction * jump_horizontal * delta

		
func player_animations():
	if current_state == states.idle:
		Animacoes.play("idle")
	elif current_state == states.run:
		Animacoes.play("run")
	elif current_state == states.jump:
		Animacoes.play("jump")

	
