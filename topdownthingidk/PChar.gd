extends CharacterBody2D

@export var bullet_scene: PackedScene
@export var speed: float = 400.0
@export var max_hp: int = 15
var hp: int
var can_take_damage: bool = true
@export var damage_cooldown: float = 0.2
var health_bar: ProgressBar
@export var normal_spread: float = 0.08        # radians (\~4.5 degrees)
@export var back_spread: float = 0.22        # more spread when shooting backwards
@export var shoot_shake_strength: float = 6.5

@onready var muzzle: Marker2D = $Muzzle
@onready var shoot_timer: Timer = $Timer

var last_direction: Vector2 = Vector2.DOWN
var can_shoot: bool = true

func _ready() -> void:
	hp = max_hp
	health_bar = get_tree().current_scene.get_node("UI/HealthBar")
	health_bar.max_value = max_hp
	health_bar.value = hp
	
	# Connect the Timer so we know when cooldown is done
	shoot_timer.timeout.connect(_on_shoot_timer_timeout)
	shoot_timer.one_shot = true

func _physics_process(delta: float) -> void:
	var input_dir = Input.get_vector("left", "right", "up", "down")

	if input_dir != Vector2.ZERO:
		last_direction = input_dir.normalized()

	velocity = input_dir * speed
	move_and_slide()

	# Normal shoot
	if Input.is_action_just_pressed("shoot") and can_shoot:
		shoot(last_direction, normal_spread)
		
		 # Shoot backwards
	if Input.is_action_just_pressed("shoot_back") and can_shoot:
		shoot(-last_direction, back_spread)

func shoot(direction: Vector2, spread: float) -> void:
	if bullet_scene == null:
		return
		
	# Apply spread
	var angle = randf_range(-spread, spread)
	var final_direction = direction.rotated(angle)
	
	# Create the bullet
	var bullet = bullet_scene.instantiate()
	get_tree().current_scene.add_child(bullet)
	bullet.global_position = muzzle.global_position
	bullet.direction = final_direction
	
	apply_shoot_shake()
	
	# Start cooldown
	can_shoot = false
	shoot_timer.start()

func apply_shoot_shake() -> void:
	var camera = get_viewport().get_camera_2d()
	if camera:
		var tween = create_tween()
		var original_offset = camera.offset
		tween.tween_property(camera, "offset", original_offset + Vector2(randf_range(-shoot_shake_strength, shoot_shake_strength), randf_range(-shoot_shake_strength, shoot_shake_strength)), 0.03)
		tween.tween_property(camera, "offset", original_offset, 0.05)

func take_damage(amount: int) -> void:
		# ignore damage while invincible
	if not can_take_damage:
		return

	hp -= amount
	health_bar.value = hp
	print("Player HP: ", hp)
	
	# Visual feedback
	modulate = Color.BLUE
	# Start invincibility
	can_take_damage = false
	# Wait for cooldown
	await get_tree().create_timer(damage_cooldown).timeout
	
	# Invincibility finished
	can_take_damage = true
	modulate = Color.WHITE
	
	if hp <= 0:
		die()

func die() -> void:
	print("player died")
	set_physics_process(false)
	set_process(false) # Disable controls
	get_tree().current_scene.get_node("GameOver").show_game_over()


func _on_shoot_timer_timeout() -> void:
# Called when the Timer finishes → we can shoot again
	can_shoot = true
