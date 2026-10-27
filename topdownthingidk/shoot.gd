extends CharacterBody2D

# move

@export var speed: float = 400.0

func get_input() -> void:
	var input_direction = Input.get_vector("left", "right", "up", "down")
	velocity = input_direction * speed

func _physics_process(delta: float) -> void:
	get_input()
	move_and_slide()

# move stop
# shoot

@export var bullet_scene: PackedScene

@onready var muzzle: Marker2D = $Muzzle
@onready var shoot_timer: Timer = $Timer

func _ready() -> void:
	shoot_timer.timeout.connect(_on_shoot_timer_timeout)

func _on_shoot_timer_timeout() -> void:
	shoot()

func shoot() -> void:
	if not bullet_scene:
		return
	var bullet = bullet_scene.instantiate()
	get_parent().add_child(bullet)

	bullet.global_position = muzzle.global_position
