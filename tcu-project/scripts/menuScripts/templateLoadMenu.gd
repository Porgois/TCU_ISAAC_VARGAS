class_name TemplateLoad
extends Control

@export var grade_tabs: HBoxContainer = null
@export var options_container: VBoxContainer = null
@export var load_button: GeneralButton = null

const TEMPLATES_PATH: String = "res://csvImports/templates/"
const COLOR_NORMAL: Color = Color("f2f2f2")
const COLOR_DIM: Color = Color("505057ff")

var general_button_scene: PackedScene = preload("res://scenes/ui/generalButton.tscn")
var grade_group: ButtonGroup = ButtonGroup.new()
var file_group: ButtonGroup = ButtonGroup.new()
var file_reader: FileReader = null
var selected_path: String = ""

func _ready() -> void:
	file_reader = FileReader.new()
	setEnabled(load_button, false)
	grade_group.pressed.connect(_on_grade_pressed)
	file_group.pressed.connect(_on_file_pressed)
	load_button.pressed.connect(_on_load_pressed)
	buildGradeTabs()

#region HELPERS

# "Unit 1 (Here I Am!).csv" -> { unit: "Unit 1", title: "Here I Am!" }
func parseUnitName(file_name: String) -> Dictionary:
	var base: String = file_name.get_basename() # Gets rid of the '.csv' termination
	var paren: int = base.find("(")
	if paren == -1:
		return {"unit": "", "title": base}
	return {
		"unit": base.substr(0, paren).strip_edges(),
		"title": base.substr(paren).trim_prefix("(").trim_suffix(")").strip_edges()
	}

# Natural sort so "Unit 10" comes after "Unit 9", and Grade 10 after Grade 9
func sortNatural(items: PackedStringArray) -> Array[String]:
	var result: Array[String] = []
	result.assign(items)
	result.sort_custom(func(a: String, b: String) -> bool:
		return a.naturalnocasecmp_to(b) < 0
	)
	return result

# Get files in a given folder (empty extension returns all files)
func getFilesInFolder(folder_path: String, extension: String = "") -> PackedStringArray:
	var result := PackedStringArray()
	for file in DirAccess.get_files_at(folder_path):
		if extension.is_empty() or file.get_extension().to_lower() == extension:
			result.append(file)
	return result

#endregion

#region FILE LOADING

# Opens file dialog and loads the selected file path if valid
func browseFile() -> void:
	var file_browser: FileBrowser = FileBrowser.new()
	get_tree().root.add_child(file_browser)
	
	var file_path: String = file_browser.openFileBrowserWindow()
	if file_path != "":
		file_reader.loadFile(file_path, get_tree())

#endregion

#region BUILD UI

# One place that makes every toggle-style GeneralButton
func makeToggleButton(text: String, group: ButtonGroup, variation: StringName, align: String = "center") -> GeneralButton:
	var button: GeneralButton = general_button_scene.instantiate()
	setButtonText(button, text, align)
	button.toggle_mode = true
	button.button_group = group
	button.theme_type_variation = variation
	setLabelColor(button, COLOR_NORMAL)
	

	return button

func setLabelColor(button: GeneralButton, color: Color) -> void:
	button.button_label.add_theme_color_override("default_color", color)

# Sets the label text with BBCode alignment. Escapes "[" so quiz names can't break the markup.
func setButtonText(button: GeneralButton, text: String, align: String = "center") -> void:
	var label: RichTextLabel = button.button_label
	label.bbcode_enabled = true
	label.scroll_active = false
	label.autowrap_mode = TextServer.AUTOWRAP_OFF
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.text = "[%s]%s[/%s]" % [align, text.replace("[", "[lb]"), align]

func setEnabled(button: GeneralButton, enabled: bool) -> void:
	button.disabled = not enabled
	setLabelColor(button, COLOR_NORMAL if enabled else COLOR_DIM)

func buildGradeTabs() -> void:
	var grades : Array[String] = sortNatural(DirAccess.get_directories_at(TEMPLATES_PATH))
	
	for grade in grades:
		var tab : GeneralButton = makeToggleButton(
			grade.replace("Grade", "Grade "), grade_group, &"SegmentTab")
		tab.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		tab.set_meta("grade", grade)
		grade_tabs.add_child(tab)
	
	if grade_tabs.get_child_count() > 0: # Select the first grade by default
		var first: GeneralButton = grade_tabs.get_child(0)
		first.button_pressed = true
		showGrade(first.get_meta("grade"))

func showGrade(grade: String) -> void:
	selected_path = ""
	setEnabled(load_button, false)
	for child in options_container.get_children():
		child.queue_free()
	
	var folder: String = TEMPLATES_PATH + grade + "/"
	var files: Array[String] = sortNatural(getFilesInFolder(folder, "csv"))
	
	if files.is_empty():
		var empty := Label.new()
		empty.text = "No quizzes for this grade yet"
		empty.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		options_container.add_child(empty)
		return
	
	for file_name in files:
		createFileButton(folder + file_name, file_name)

func createFileButton(full_path: String, file_name: String) -> void:
	var parts: Dictionary = parseUnitName(file_name)
	var text: String = parts.title if parts.unit.is_empty() else parts.unit + "    " + parts.title
	
	var button: GeneralButton = makeToggleButton(text, file_group, &"ListRow", "left")
	button.custom_minimum_size.y = 48
	button.button_label.clip_contents = true
	button.set_meta("path", full_path)
	options_container.add_child(button)

#endregion

#region SIGNALS

func _on_grade_pressed(button: BaseButton) -> void:
	showGrade(button.get_meta("grade"))

func _on_file_pressed(button: BaseButton) -> void:
	selected_path = button.get_meta("path")
	setEnabled(load_button, true)

func _on_load_pressed() -> void: # Connect LoadButton.pressed to this
	if selected_path != "":
		file_reader.loadFile(selected_path, get_tree())

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Menus/MainMenu.tscn")

func _on_browse_pressed() -> void:
	browseFile()

#endregion
