extends Sprite2D

func _ready() -> void:
	var tween = create_tween()
	tween.set_loops() # boucle infinie
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_IN_OUT)
	var base_scale = scale
	tween.tween_property(self, "scale", base_scale * 1.5, 1)
	tween.tween_property(self, "scale", base_scale, 1)
