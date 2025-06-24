extends CharacterBody2D

@onready var animation: AnimationPlayer = $body/animacoes
@onready var timer: Timer = $Timer

@export var patrol_points: Node
@export var speed: int = 1500
@export var wait_time : int = 3

const gravity = 1000
var direction = Vector2.LEFT
enum state{idle, run, hurt, attack,death, react}
var current_state : state
var number_of_points : int
var points_positions : Array[Vector2]
var current_point: Vector2
var current_point_position: int
var can_walk : bool

func _ready():
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
		
func enemy_animations():
	if current_state == state.idle && !can_walk:
		animation.play("idle")
	elif current_state == state.run && can_walk:
		animation.play("run")
		
func _on_timer_timeout():
	can_walk = true
