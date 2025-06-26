extends Node3D

@onready var mesh: Node3D = $Sketchfab_model
@onready var ray: RayCast3D = $RayCast3D
@onready var particles = $GPUParticles3D

var speed = 50

func _process(delta: float) -> void:
	position += global_transform.basis * Vector3(0,0,-speed) * delta
	if ray.is_colliding():
		mesh.visible = false
		particles.emitting = true
		await get_tree().create_timer(1.0).timeout
		queue_free()


func _on_timer_timeout() -> void:
	queue_free()
	
