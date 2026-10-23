class_name CustomQuizMenu
extends Control

@export var quizzes_container : VBoxContainer = null
var custom_quiz_item_scene : PackedScene = preload("res://scenes/ui/customQuestion/questionItems/customQuizItem.tscn")

func _ready() -> void:
	addItemPerFile(QuizSession.CUSTOM_QUIZ_PATH)

#region BASICS

# Adds one quiz item per .csv file inside the folder
func addItemPerFile(folder_path : String) -> void:
	clearQuizItems()
	
	if not DirAccess.dir_exists_absolute(folder_path):
		printerr("[CUSTOM QUIZ MENU] Folder not found: ", folder_path, "\n")
		return
	
	var files : PackedStringArray = DirAccess.get_files_at(folder_path)
	files.sort()
	for file_name in files:
		if file_name.get_extension().to_lower() == "csv":
			addQuizItem(folder_path.path_join(file_name))

func clearQuizItems() -> void:
	if quizzes_container == null:
		return
	
	for child in quizzes_container.get_children():
		quizzes_container.remove_child(child)
		child.queue_free()

# Adds an item for an existing quiz
func addQuizItem(csv_path : String) -> void:
	var new_quiz_item : CustomQuizItem = custom_quiz_item_scene.instantiate()
	
	# Setup
	setupNewQuizItem(new_quiz_item, csv_path.get_file().get_basename(), csv_path)
	
	# Add to container
	if quizzes_container:
		quizzes_container.add_child(new_quiz_item)
		new_quiz_item.setQuizNumberText(quizzes_container.get_child_count())

func setupNewQuizItem(quiz_item : CustomQuizItem = null, quiz_name : String = "", csv_path : String = ""):
	quiz_item.quiz_path = csv_path
	quiz_item.setQuizNameText(quiz_name)

# Adds an entirely new quiz
func addNewQuizItem():
	QuizSession.pending_csv_path = ""  # empty (new quiz)
	get_tree().change_scene_to_file(QuizSession.CREATOR_SCENE_PATH)

#endregion

#region SIGNALS

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menus/MainMenu.tscn")

func _on_new_quiz_pressed() -> void:
	addNewQuizItem()

#endregion
