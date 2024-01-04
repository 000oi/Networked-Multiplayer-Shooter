extends CanvasLayer

func _ready() -> void:
	Globals.ui = self
func _exit_tree() -> void:
	Globals.ui = null
