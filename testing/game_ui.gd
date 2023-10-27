extends CanvasLayer

signal r

@export var cursor_color_speed:float = 1.0
@export var cursor_base:Texture2D
@export var cursor_active:Texture2D
@onready var cursor:TextureRect = %Cursor

var interact_in_range:bool = false
var colors:Array[Color] = [Color.WHITE, Color.RED, Color.ORANGE, Color.YELLOW, Color.GREEN, Color.BLUE, Color.INDIGO, Color.VIOLET]
var color_index:int = 0
var color_trans:float = 0.0

func _process(delta):
	if interact_in_range:
		if color_trans >= 1.0:
			color_trans = 0
			color_index = (color_index + 1) % colors.size()
		color_trans += delta * cursor_color_speed
		cursor.modulate = colors[color_index].lerp(colors[(color_index + 1) % colors.size()], color_trans)

func _ready():
	var player:CharacterBody3D = self.get_parent().get_node("%Player")
	if player:
		player.interact_enter.connect(interact_enter)
		player.interact_exit.connect(interact_exit)

func interact_enter():
	cursor.texture = cursor_active
	interact_in_range = true
	
func interact_exit():
	cursor.texture = cursor_base
	interact_in_range = false
