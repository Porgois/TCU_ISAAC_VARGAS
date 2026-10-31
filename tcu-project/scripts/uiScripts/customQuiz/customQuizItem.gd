class_name CustomQuizItem
extends MarginContainer

@export var quiz_name : RichTextLabel = null
@export var quiz_number : RichTextLabel = null

var associated_quiz : Quiz = null
var quiz_path : String = ""  # The .csv this item represents, set by the quiz list
var quiz_creation_scene_path : String = "res://scenes/ui/customQuestion/customQuizCreator.tscn"

#region QUIZ_INFO

func setQuizNumberText(number : int = 1):
	if quiz_number:
		quiz_number.text = str(number) + "."

func setQuizNameText(new_text : String = ""):
	if quiz_name:
		quiz_name.text = new_text

#endregion

# Tells the creator which quiz to load once the scene changes
func setCreatorEnvironment():
	QuizSession.pending_csv_path = quiz_path

func goToQuizCreator():
	get_tree().change_scene_to_file(quiz_creation_scene_path)

func deleteQuiz():
	var file_reader : FileReader = FileReader.new()
	file_reader.deleteQuiz("res://csvImports/customQuizzes/" + quiz_name.text + ".csv")
	MessageNotifier.showMessage(get_tree(), "Quiz deleted succesfully!\n")
	get_tree().reload_current_scene()

#region SIGNALS

func _on_edit_button_pressed() -> void:
	setCreatorEnvironment()
	goToQuizCreator()

func _on_delete_button_pressed() -> void:
	if await ConfirmationModal.ask("Delete quiz?", "This action cannot be undone."):
		deleteQuiz()

#endregion
