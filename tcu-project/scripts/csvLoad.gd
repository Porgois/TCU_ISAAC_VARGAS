class_name FileReader
extends Node

func loadCSVAsArray(csv_path: String) -> Array:
	var text_array : Array = []
	
	# Load file
	var file = FileAccess.open(csv_path, FileAccess.READ)
	
	if (file == null):
		printerr("ERROR: no '.CSV' file found at: ", csv_path)
		return text_array
	
	# Read file
	while not file.eof_reached():
		var line = file.get_line()
		
		if line.strip_edges() == "":
			continue
		
		var line_column = line.split(",")
		text_array.append(line_column)
		
	# Close file
	file.close()
	# Return read text array
	return text_array

# Return an array of questions
func textToQuestions(text_array: Array) -> Array[Question]:
	var questions: Array[Question] = []
	var current_question: Question = null

	for element in text_array:
		# Pad the element so we can safely access index 0 and 1
		while element.size() < 2:
			element.append("")

		var cell_a: String = element[0].strip_edges()
		var cell_b: String = element[1].strip_edges()
		var is_correct: bool = cell_b.to_lower() == "true"

		if cell_b == "":
			# No value in column B → this is a question prompt row
			if current_question != null:
				questions.append(current_question)

			current_question = Question.new()
			current_question.setQuestionPrompt(cell_a)
		else:
			# Has a column B value (option row)
			if current_question == null:
				printerr("WARNING: Option row found before any question prompt: ", element)
				continue

			var option = QuestionOption.new()
			option.text = cell_a
			option.is_correct = is_correct
			current_question.addQuestionOption(option)

	# Save last question
	if current_question != null:
		questions.append(current_question)

	return questions


func printQuestions(questions: Array[Question]):
	for q in questions:
		print("Question: ", q.question_prompt)
		for opt in q.options:
			print("  Option: ", opt.text, " | Correct: ", opt.is_correct)
		print("")
