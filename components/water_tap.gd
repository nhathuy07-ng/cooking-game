extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("jug"):
		$Area2D/AnimatedSprite2D.frame = 1
	pass # Replace with function body.


func _on_area_2d_area_exited(area: Area2D) -> void:
	if area.is_in_group("jug"):
		$Area2D/AnimatedSprite2D.frame = 0
	pass # Replace with function body.
