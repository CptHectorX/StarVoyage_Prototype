extends Node3D

# --- Tuning values (adjust to taste later) ---
@export var thrust_power: float = 20.0   # how hard the engines push
@export var max_speed: float = 40.0      # speed cap

# --- Runtime state ---
var velocity: Vector3 = Vector3.ZERO     # current movement vector (Newtonian)

func _physics_process(delta: float) -> void:
	# Build the thrust direction from input, relative to where the ship faces
	var input_dir: Vector3 = Vector3.ZERO

	if Input.is_action_pressed("thrust_forward"):
		input_dir -= transform.basis.z   # -Z is "forward" in Godot
	if Input.is_action_pressed("thrust_back"):
		input_dir += transform.basis.z   # +Z is "backward"
	if Input.is_action_pressed("strafe_left"):
		input_dir -= transform.basis.x   # -X is "left"
	if Input.is_action_pressed("strafe_right"):
		input_dir += transform.basis.x   # +X is "right"

	# Apply thrust to velocity (Newtonian: we add, never auto-subtract)
	velocity += input_dir * thrust_power * delta

	# Cap the speed so it doesn't grow forever
	velocity = velocity.limit_length(max_speed)

	# Move the ship by its current velocity
	global_position += velocity * delta
