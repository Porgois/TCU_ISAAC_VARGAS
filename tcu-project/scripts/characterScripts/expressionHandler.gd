class_name ExpressionHandler
extends Node

# Eye and mouth animators
@export var eye_animator : AnimationPlayer = null
@export var mouth_animator : AnimationPlayer = null

# Emotions
enum EMOTION {
	NEUTRAL,
	ANGRY,
	SAD
}

var current_emotion : EMOTION = EMOTION.NEUTRAL

func _ready() -> void:
	Global.setExpressionHandler(self) # Set to self for later use

#region BASICS

func changeEmotion(new_emotion : EMOTION = EMOTION.NEUTRAL):
	current_emotion = new_emotion
	print("[EXPRESSION HANDLER] Set new emotion to: ", current_emotion, ".\n")

#endregion

#region ANIMATIONS

# Play blink animation according to emotion
func play_blink_animation():
	if eye_animator == null:
		printerr("[EXPRESSION HANDLER] Error: No eye animation player has been set!\n")
		return
	
	# Map emotion to prefix
	var animation_prefix : String = ""
	match current_emotion:
		EMOTION.NEUTRAL:
			animation_prefix = "neutral"
	
	# Play animation
	eye_animator.play("EyeAnimations/" + animation_prefix + "_blink")

# Play speak animation according to emotion
func play_speak_animation():
	if mouth_animator == null:
		printerr("[EXPRESSION HANDLER] Error: No mouth animation player has been set!\n")
		return
	
	# Map emotion to prefix
	var animation_prefix : String = ""
	match current_emotion:
		EMOTION.NEUTRAL:
			animation_prefix = "neutral"
	
	# Play animation
	mouth_animator.play("MouthAnimations/" + animation_prefix + "_speak")

#endregion
