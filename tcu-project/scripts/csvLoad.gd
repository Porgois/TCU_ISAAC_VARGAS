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
func textToQuestion(text_array : Array) -> Array[Question]:
	var questions : Array[Question] = []
	
	for element in text_array:
		if element.size() < 2:
			continue
			
		var question : Question = Question.new()
		question.text = element[0]
		question.is_correct = element[1].to_lower() == "true" # yes if 'TRUE' no if anything else
		
		questions.append(question)
		
	return questions

func printCSVArray(text_array : Array):
	if (!text_array.is_empty()):
		print("FILE CONTENT:\n")
		for element in text_array:
			print(element)
