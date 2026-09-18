class_name ImageGenerator
extends Node

# Image
var image_width : int = 800
var image_height : int = 600
var default_color : Color = Color.BLACK
var default_export_path : String = "res://completionImages/img_test.png"

# Font
var font_size : int = 32

# Labels
var label_gap : float = 30.0
var pred_score_text : String = "Your score was: "

func createImage(title_text : String = "Congratulations", score_text : String = "No score provided!", width : int = image_width, \
	height : int = image_height, color : Color = default_color) -> bool:
	# Create viewport and set values
	var viewport : SubViewport = SubViewport.new()
	viewport.size = Vector2i(width, height)
	viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	viewport.transparent_bg = true
	add_child(viewport)
	
	# Background
	var bg : ColorRect = ColorRect.new()
	bg.color = default_color
	bg.size = Vector2(width, height)
	viewport.add_child(bg)
	
	# Center
	var center : CenterContainer = CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	viewport.add_child(center)
	
	# Vertical text alignment
	var vbox : VBoxContainer = VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", int(label_gap))
	center.add_child(vbox)
	
	# Add text labels
	addLabel(vbox, title_text + QuizManager.getUserName() + "!")
	addLabel(vbox, pred_score_text + score_text)
	
	# Viewport render
	await RenderingServer.frame_post_draw
	
	# Save image & clean-up
	var img : Image = viewport.get_texture().get_image()
	var err : Error = img.save_png(default_export_path)
	
	viewport.queue_free()
	
	# Check for errors
	if err != OK:
		push_error("[IMAGE CREATION] Error: Failed to save image! (error %d)" % err)
		return false
	
	print("[IMAGE CREATION] Image saved succesfully to: %s" % default_export_path)
	return true

func addLabel(vbox : VBoxContainer, text : String = "No text given!"):
	# Label
	var label : Label = Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", font_size)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(label)
