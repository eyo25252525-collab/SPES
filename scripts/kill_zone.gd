extends Area2D

@onready var timer: Timer = $Timer
@onready var fade: Fade = $Fade

const SPIN_DURATION = 0.6  # durée d'un tour complet (en secondes)
const JUMP_POWER = -300
var triggered = false

func _on_body_entered(body: Node2D) -> void:
	if triggered:
		return
	triggered = true	
	fade.animation_player.play("fade_in")
	Engine.time_scale = 0.5
	body.get_node("CollisionShape2D").queue_free()

	# Rotation infinie du body
	var tween := body.create_tween().set_loops()
	tween.tween_property(body, "rotation", TAU, SPIN_DURATION).as_relative()

	timer.start()


func _on_timer_timeout() -> void:
	Engine.time_scale = 1
	await fade.animation_player.animation_finished
	get_tree().reload_current_scene()
