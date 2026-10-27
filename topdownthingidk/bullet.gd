extends Area2D

@export var speed: float = 600.0
@export var damage: int = 1

var direction: Vector2 = Vector2.UP #shoots up on default

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	# print("Bullet ready, monitoring = ", monitoring)
	# print("Bullet ready, mask = ", get_collision_mask())

func _on_body_entered(body: Node2D) -> void:
	print("BODY entered: ", body.name)
	if body.is_in_group("player"):
		return
	if body.has_method("take_damage"):
		body.take_damage(damage)
	call_deferred("queue_free")

func _physics_process(delta: float) -> void:
	position += direction * speed * delta

func _on_screen_exited() -> void:
	call_deferred("queue_free")
