extends Marker2D

@export var enemy_scene: PackedScene
@export var spawn_interval: float = 3.0

func _ready() -> void:
	# Start spawning
	spawn_enemy()
	# Repeat every X seconds
	var timer = Timer.new()
	timer.wait_time = spawn_interval
	timer.autostart = true
	timer.timeout.connect(spawn_enemy)
	add_child(timer)

func spawn_enemy() -> void:
	if enemy_scene == null:
		push_warning("Enemy scene not assigned!")
		return
	
	var enemy = enemy_scene.instantiate()
	get_tree().current_scene.add_child.call_deferred(enemy)
	enemy.global_position = global_position
