extends CharacterBody2D


const SPEED = 100.0
const JUMP_VELOCITY = -300.0
const DASH_VELOCITY = -140.0;
const ROLL_VELOCITY = -300.0;	

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var area_2d: Area2D = $Area2D
@onready var timer: Timer = $Timer
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var dash_particles: GPUParticles2D = $DashParticles
@onready var dust_particles: GPUParticles2D = $DustParticles
@onready var roll_particles: GPUParticles2D = $RollParticles


var isDashing = false;
var canDash = true;

var isRolling = false;
var canRoll = true;

func _physics_process(delta: float) -> void:
	
	if is_on_floor() and timer.is_stopped():		
		canDash = true
		canRoll = true
	
	# Add the gravity.
	if not is_on_floor() && !isDashing && !isRolling:
		velocity += get_gravity() * delta
		animated_sprite_2d.play("jump")
		#print(velocity.y)
	
	if Input.is_action_just_pressed("dash") && canDash && !isRolling:
		isDashing = true	
		canDash = false		
		timer.start()	
			
	if Input.is_action_just_pressed("roll") && canRoll && !isDashing:
		isRolling = true	
		canRoll = false
		timer.start()
			
	if isDashing:		
			dash_particles.emitting = true
			animated_sprite_2d.play("dash")			
			velocity.y = 0;
			if animated_sprite_2d.flip_h == true:				
				velocity.x += DASH_VELOCITY
			else:				
				velocity.x -= DASH_VELOCITY
			roll_particles.emitting = false
	elif isRolling:		
			roll_particles.emitting = true
			animated_sprite_2d.play("roll")			
			velocity.y = ROLL_VELOCITY;			
			velocity.x = 0	
	else: 
		dash_particles.emitting = false
		roll_particles.emitting = false
	# Handle jump.
	if Input.is_action_pressed("jump") and is_on_floor() and !isDashing:
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("left", "right")
	if direction and !isDashing and !isRolling:
		if is_on_floor():
			dust_particles.emitting = true
			animated_sprite_2d.play("walk")
		else:			
			dust_particles.emitting = false
		velocity.x = direction * SPEED
		if direction < 0:
			animated_sprite_2d.flip_h = true
			dash_particles.scale.x = -1;
		else:
			animated_sprite_2d.flip_h = false
			dash_particles.scale.x = 1;
			
	else:
		dust_particles.emitting = false
		velocity.x = move_toward(velocity.x, 0, SPEED)
		if is_on_floor() and !isDashing:
			animated_sprite_2d.play("idle")

	move_and_slide()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name != "Player":
		isDashing = false
		isRolling = false
	timer.stop()
	
func _ready() -> void:
	canDash = true
	canRoll = true

func _on_timer_timeout() -> void:
	if isDashing:
		isDashing = false
		canDash = false
	elif isRolling:
		isRolling = false
		canRoll = false	
	timer.stop()


func _on_area_2d_body_exited(body: Node2D) -> void:
	pass
