extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$Score.text = str(Globals.dishesDone)
	
	if Globals.potRemaining <= 0 or Globals.panRemaining <= 0:
		get_tree().change_scene_to_file("res://assets/gameover.tscn")
	
	pass
