class_name MultipleChoiceQuestionPrompter
extends GeneralQuestionPrompter

@export var max_options : int = 4

var question_options : Array[String] = []
var correct_group : ButtonGroup = ButtonGroup.new()  # Makes the correct-answer checks mutually exclusive

func _ready() -> void:
	# Fixed number of rows: the menu already made the first one, so create the rest
	var menu : QuestionAnswerMenu = getAnswerMenu()
	if menu != null:
		menu.max_answer_count = max_options
		menu.ensureAnswerCount(max_options, false)  # false = no delete buttons
	
	question_answers_container.child_entered_tree.connect(onAnswerRowAdded)
	for row in question_answers_container.get_children():
		onAnswerRowAdded(row)  # shows the correct-answer check and joins the group

func onAnswerRowAdded(row : Node) -> void:
	var answer_row : QuestionAnswer = row as QuestionAnswer
	if answer_row != null:
		answer_row.setCorrectCheckVisible(true)
		answer_row.setCorrectGroup(correct_group)

#region LOADING

func loadFromQuestion(question : Question) -> void:
	question_input.setInputText(question.question)
	
	var options : Array[String] = getLimitedOptions(question)
	fillAnswerRows(options)
	
	var rows : Array[Node] = question_answers_container.get_children()
	for i in rows.size():
		var row : QuestionAnswer = rows[i] as QuestionAnswer
		if row != null:
			row.setCorrect(i < options.size() and question.answers.has(options[i]))

# A hand-edited CSV could have more options than allowed
func getLimitedOptions(question : Question) -> Array[String]:
	var options : Array[String] = []
	options.assign(question.options.slice(0, max_options))
	
	if question.options.size() > max_options:
		printerr("[MC QUESTION PROMPTER] Warning: question has ", question.options.size(), \
			" options but only ", max_options, " are allowed. The rest will be dropped on the next save!\n")
		# Never drop the correct answer
		for answer in question.answers:
			if question.options.has(answer) and not options.has(answer):
				options[max_options - 1] = answer
	
	return options

#endregion

#region SAVING

func setAnswers() -> void:
	question_answer_texts.clear()
	question_options.clear()
	
	for node in question_answers_container.get_children():
		var row : QuestionAnswer = node as QuestionAnswer
		if row == null or row.is_queued_for_deletion():
			continue
		
		var text : String = row.getInputText().strip_edges()
		if text == "":
			continue
		
		question_options.append(text)
		if row.isCorrect() and question_answer_texts.is_empty():  # Only one correct answer
			question_answer_texts.append(text)
		
		if question_options.size() >= max_options:  # Never save more than max_options
			break

func setQuestionAnswers() -> void:
	var question_item = associated_creation_modal.getQuestionItem()
	if question_item != null:
		question_item.associated_question.options.assign(question_options)
		question_item.associated_question.answers.assign(question_answer_texts)

#endregion
