extends Node

# lança um projétil
func shoot(projectile : PackedScene, where_should_create : Node, position : Vector2, direction : int):
	var projectile_instance = projectile.instantiate()
	where_should_create.add_sibling(projectile_instance, true)
	
	projectile_instance.set_direction(sign(direction))
	projectile_instance.position = position

# Faz aparecer um summon na posicao especificada
func summon(summon_object : PackedScene, where_should_create : Node, position : Vector2):
	var summon_instance = summon_object.instantiate()
	where_should_create.add_sibling(summon_instance, true)
	
	summon_instance.position = position
	
# Faz o sprite piscar em branco, informando que tomou um hit
func hit_blink(sprite : Node):
	sprite.self_modulate = Color(50,50,50,1)
	await get_tree().create_timer(0.1).timeout
	sprite.self_modulate = Color(1,1,1,1)

# Calcula a distancia entre o mob e o alvo
func distance_to(node : Node, target : Node):
	var distance = node.global_position.distance_to(target.global_position)
	return distance

# Verifica se o mob esta exatamente abaixo do nó alvo
func is_below(parent : Node, target : Node):
	var horizontal_difference = abs(parent.global_position.x - target.global_position.x)
	var is_below_target = parent.global_position.y > target.global_position.y or parent.global_position.y < target.global_position.y
	var is_exactly_below = horizontal_difference < 2 and is_below_target
	
	return is_exactly_below

# faz o mob ficar estunado
func take_stun(target: Node, duration := 2.0):
	target.is_stuned = true
	await get_tree().create_timer(duration).timeout

	# se o mob ainda estiver vivo, ele desativa a stun
	if is_instance_valid(target):
		target.is_stuned = false

# Aplica dano ao mob
func apply_damage(target: Node, damage: int):
	if target.is_dead or damage == 0:
		return false
	
	target.is_damaged = true
	target.life -= damage *2 if target.is_stuned else damage
	
	if target.life <= 0:
		target.is_dead = true
	return true
