extends CharacterBody2D

@export var speed: float = 150.0
@export var max_hp: int = 2
@export var separation_radius: float = 28.0
@export var separation_strength: float = 80.0

var hp: int
var player: Node2D = null

func _ready() -> void:
	hp = max_hp
	add_to_group("enemies")   # useful later
	player = get_tree().get_first_node_in_group("player") # Find the player
	
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING

func _physics_process(delta: float) -> void:
	if player == null or not is_instance_valid(player):
		velocity = Vector2.ZERO
		return
	
	# 1. Seek the player
	var seek_dir = (player.global_position - global_position).normalized()
	
	# 2. Separation (push away from nearby enemies)
	var separation = Vector2.ZERO
	var enemies = get_tree().get_nodes_in_group("enemies")
	
	for other in enemies:
		if other == self or not is_instance_valid(other):
			continue
		
		var offset = global_position - other.global_position
		var dist = offset.length()
		
		if dist < separation_radius and dist > 0:
			separation += offset.normalized() / dist
	
	# Combine forces
	var final_dir = seek_dir
	if separation != Vector2.ZERO:
		final_dir = (seek_dir + separation.normalized() * 0.8).normalized()
	
	velocity = final_dir * speed
	move_and_slide()
	
	# Touch detection
	for i in get_slide_collision_count():
		var collider = get_slide_collision(i).get_collider()
	
	move_and_slide()
	
	# Checking for touch
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		
		if collider and collider.is_in_group("player"):
			# print("Enemy touched the player")
			
			collider.take_damage(1)

func take_damage(amount: int) -> void:
	hp -= amount
	print("Enemy hit! HP left: ", hp)
	
	# flash effect
	modulate = Color.BLUE
	await get_tree().create_timer(0.1).timeout
	modulate = Color.VIOLET
	
	if hp <= 0:
		die()

func die() -> void:
	print("Enemy died!")
	queue_free()
