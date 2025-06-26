extends CharacterBody3D

#player nodes
@onready var head: Node3D = $head
@onready var standing_collsion_shape: CollisionShape3D = $standing_collsion_shape
@onready var crouching_collsion_shape: CollisionShape3D = $crouching_collsion_shape
@onready var ray_cast_3d: RayCast3D = $RayCast3D
@onready var gun: Node3D = $head/Camera3D/Gun/RayCast3D
@onready var gun_anim: AnimationPlayer = $head/Camera3D/Gun/AnimationPlayer


#speed vars
var current_speed = 5.0
const walking_speed =5.0
const crouching_speed =3.0
const sprinting_speed =10.0

#direction vars
const jump_velocity = 4.5
var lerp_speed = 10.0
var direction = Vector3.ZERO

#input vars

var crouching_depth = -0.5
const mouse_sens = 0.27

#bullet
var bullet = load("res://scenes/bullet.tscn")
var instance




func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sens))
		head.rotate_x(deg_to_rad(-event.relative.y * mouse_sens))
		head.rotation.x=clamp(head.rotation.x,deg_to_rad(-89),deg_to_rad(89))

func _physics_process(delta: float) -> void:
	
	#crouch and sprint
	if Input.is_action_pressed("crouch"):
		current_speed = crouching_speed
		head.position.y = lerp(head.position.y,1.8 + crouching_depth,delta*lerp_speed)
		standing_collsion_shape.disabled = true
		crouching_collsion_shape.disabled = false
	elif !ray_cast_3d.is_colliding():
		standing_collsion_shape.disabled = false
		crouching_collsion_shape.disabled = true
		head.position.y = lerp(head.position.y,1.8,delta*lerp_speed)
		if  Input.is_action_pressed("sprint"):
			current_speed=sprinting_speed
		else:
			current_speed=walking_speed
			
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	direction = lerp(direction,(transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(),delta*lerp_speed)
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)

	move_and_slide()
	
	#shooting
	if Input.is_action_just_pressed("shoot"):
		if !gun_anim.is_playing():
			gun_anim.play("shoot")
			instance = bullet.instantiate()
			instance.position = gun.global_position
			instance.transform.basis = gun.global_transform.basis
			get_parent().add_child(instance)

			# Enemy hit detection
			if gun.is_colliding():
				var hit = gun.get_collider()
				if hit and hit.has_method("take_damage"):
					hit.take_damage(25)
