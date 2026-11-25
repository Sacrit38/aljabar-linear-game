extends CharacterBody3D

@export var cruise_speed: float = 25.0
@export var turn_rate: float = 2.5        # Radians/sec for pitch & yaw
@export var bank_angle: float = 0.65      # Max roll tilt in radians (~37 deg)
@export var bank_smooth: float = 5.0
@export var origin : Node3D

func _physics_process(delta: float) -> void:
	var turn_input: float = Input.get_axis("move_left", "move_right") 
	var pitch_input: float = Input.get_axis("move_down", "move_up") 

	var forward: Vector3 = -global_transform.basis.z
	var right: Vector3 = global_transform.basis.x
	var up: Vector3 = global_transform.basis.y
	var dist: Vector3 = global_position - origin.global_position

	# 2. Build desired direction in 3D space from current heading + WASD
	var wish_dir: Vector3 = (forward + right * turn_input + up * pitch_input).normalized()
	#var wish_dir: Vector3 = forward
	var norm_dist: Vector3 = dist.normalized()
	var length: float = dist.length()
	print(length)
	
	var dist_forward_dot: float = norm_dist.dot(forward)
	
	print(dist_forward_dot)

	# 3. Dot products measure alignment & directional error
	var forward_dot: float = forward.dot(wish_dir) # 1.0 = on target
	var right_dot: float = right.dot(wish_dir)     # + right, - left
	var up_dot: float = up.dot(wish_dir)           # + up, - down
	

	# Scale turn speed up slightly when sharply off-axis (1.0 - forward_dot)
	var turn_boost: float = 1.0 + (1.0 - forward_dot) * 0.8

	# 4. Rotate pitch & yaw proportionally to dot-product results
	rotate_object_local(Vector3.UP, -right_dot * turn_rate * turn_boost * delta)
	rotate_object_local(Vector3.RIGHT, up_dot + -dist_forward_dot * turn_rate * turn_boost * delta / (length / 360))

	# 5. Bank (roll) wings into the turn based on right_dot, level out when straight
	var target_roll: float = -right_dot * bank_angle
	rotation.z = lerp_angle(rotation.z, target_roll, bank_smooth * delta)

	# 6. Thrust along the nose, scaled slightly by forward alignment
	var speed_factor: float = clampf(0.6 + 0.4 * forward_dot, 0.5, 1.0)
	velocity = (-global_transform.basis.z) * cruise_speed * speed_factor

	move_and_slide()
