extends CharacterBody3D

@export var speed = 4.0
@export var health = 100

var player

func _ready():
	player = get_tree().get_root().get_node("Main/Player") # Update path if needed
	$Timer.start()

func _on_Timer_timeout():
	if player:
		$NavigationAgent3D.target_position = player.global_transform.origin

func _physics_process(delta):
	if $NavigationAgent3D.is_navigation_finished():
		return
	var next_point = $NavigationAgent3D.get_next_path_position()
	var direction = (next_point - global_transform.origin).normalized()
	velocity = direction * speed
	move_and_slide()

func take_damage(amount):
	health -= amount
	if health <= 0:
		queue_free()
