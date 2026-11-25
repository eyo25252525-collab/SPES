extends CharacterBody2D

const SPEED = 100.0
const JUMP_VELOCITY = -300.0
const DASH_SPEED = 500   # vitesse pendant le dash (à ajuster)
const VERTICAL_ROLL_VELOCITY = -300.0
const HORIZONTAL_ROLL_VELOCITY = 300.0


@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var area_2d: Area2D = $Area2D
@onready var timer: Timer = $Timer   # = durée MAX du dash/roll (wait_time, One Shot activé)
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var dash_particles: GPUParticles2D = $DashParticles
@onready var dust_particles: GPUParticles2D = $DustParticles
@onready var roll_particles: GPUParticles2D = $RollParticles

var isDashing = false
var canDash = true

var isRolling = false
var canRoll = true

func _ready() -> void:
	canDash = true
	canRoll = true

func _physics_process(delta: float) -> void:

	# Recharge au sol dès que le dash/roll est terminé
	if is_on_floor() and !isDashing and !isRolling:
		canDash = true
		canRoll = true

	# Gravité
	if not is_on_floor() and !isDashing and !isRolling:
		velocity += get_gravity() * delta
		animated_sprite_2d.play("jump")

	# --- Démarrage ---
	if Input.is_action_just_pressed("dash") and canDash and !isRolling:
		isDashing = true
		canDash = false
		timer.start()

	if Input.is_action_just_pressed("roll") and canRoll and !isDashing:
		isRolling = true
		canRoll = false
		timer.start()

	# --- Arrêt si on relâche la touche ---
	if isDashing and !Input.is_action_pressed("dash"):
		stop_actions()
	if isRolling and !Input.is_action_pressed("roll"):
		stop_actions()

	# --- Effets du dash / roll (tant que la touche est maintenue) ---
	if isDashing:
		dash_particles.emitting = true
		roll_particles.emitting = false
		animated_sprite_2d.play("dash")
		velocity.y = 0
		var dash_dir = -1 if animated_sprite_2d.flip_h else 1
		velocity.x = dash_dir * DASH_SPEED
	elif isRolling:
		dash_particles.emitting = false
		roll_particles.emitting = true
		animated_sprite_2d.play("roll")
		var dash_dir = -1 if animated_sprite_2d.flip_h else 1
		velocity.x = dash_dir * HORIZONTAL_ROLL_VELOCITY		
		velocity.y = VERTICAL_ROLL_VELOCITY
	else:
		dash_particles.emitting = false
		roll_particles.emitting = false

	# Saut
	if Input.is_action_just_pressed("jump") and is_on_floor() and !isDashing and !isRolling:
		velocity.y = JUMP_VELOCITY

	# Déplacement normal
	var direction := Input.get_axis("left", "right")
	if !isDashing and !isRolling:
		if direction:
			if is_on_floor():
				dust_particles.emitting = true
				animated_sprite_2d.play("walk")
			else:
				dust_particles.emitting = false
			velocity.x = direction * SPEED
			if direction < 0:
				animated_sprite_2d.flip_h = true
				dash_particles.scale.x = -1
			else:
				animated_sprite_2d.flip_h = false
				dash_particles.scale.x = 1
		else:
			dust_particles.emitting = false
			velocity.x = move_toward(velocity.x, 0, SPEED)
			if is_on_floor():
				animated_sprite_2d.play("idle")
	else:
		dust_particles.emitting = false

	move_and_slide()


func stop_actions() -> void:
	isDashing = false
	isRolling = false
	timer.stop()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name != "Player":
		stop_actions()


func _on_timer_timeout() -> void:
	isDashing = false
	isRolling = false
	timer.stop()
