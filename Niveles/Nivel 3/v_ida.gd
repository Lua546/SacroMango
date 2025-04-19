extends Control

@onready var barra = $TextureProgressBar

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	barra.value = 100


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	barra.value = Global.vida
	#$Label.text = str(Global.vida)
