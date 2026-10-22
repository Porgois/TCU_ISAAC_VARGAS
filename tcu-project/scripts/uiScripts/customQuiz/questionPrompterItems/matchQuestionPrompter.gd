class_name MatchQuestionPrompter
extends GeneralQuestionPrompter

# Containers a -> b / term -> definition
@export var term_container : VBoxContainer = null
@export var definition_container : VBoxContainer = null

var question_prompt : String = "Match each expression with its use."
var question_pairs : Array[Question.Pair] = []

#region QUESTION PAIRS

# Creates and adds new match pair to the pair array
func addMatchPair(text_a : String = "", text_b : String = ""):
	var new_pair : Question.Pair = Question.Pair.new()
	new_pair.term = text_a
	new_pair.definitions = [text_b] # Only one element for the array
	question_pairs.push_back(new_pair)

# Prints pair at index "n"
func printPair(index : int = 0):
	print("Pair #", index, "\nTerm: ", question_pairs[index].term, \
		"\nDefinition: ", question_pairs[index].definitions[0])

# Prints all question pairs
func printPairs():
	print("PRINT PAIRS")
	for index in question_pairs.size():
		printPair(index)

#endregion

#region SYNCHING

# Get term at index 'n' from term container
func getTerm(index : int = 0) -> String:
	var result : String = ""
	
	if term_container:
		result = term_container.get_child(index).getInputText()
	return result
	
# Get definition at index 'n' from term container
func getDefinition(index : int = 0) -> String:
	var result : String = ""
	
	if definition_container:
		result = definition_container.get_child(index).getInputText()
	return result

# Set term at index 'n' in the term container
func setTerm(index : int = 0, text : String = ""):
	if term_container:
		term_container.get_child(index).setInputText(text)

# Set definition at index 'n' in the definition container
func setDefinition(index : int = 0, text : String = ""):
	if definition_container:
		definition_container.get_child(index).setInputText(text)

# Creates new match pair with the containers' data
func syncContainersWithPairs():
	# Clear first if they exist
	if question_pairs != []:  # Not empty? Clear
		question_pairs.clear()
	
	for index in term_container.get_child_count(): # a or b, both have the same amount of children
		var term : String = getTerm(int(index)).strip_edges()
		var definition : String = getDefinition(int(index)).strip_edges()
		
		if term == "" and definition == "": # Unused row, don't save an empty pair
			continue
		
		addMatchPair(term, definition)

# Opposite of syncContainersWithPairs(): fills the containers with the given pairs
func syncPairsWithContainers(pairs : Array[Question.Pair]):
	var row_count : int = mini(term_container.get_child_count(), definition_container.get_child_count())
	
	if pairs.size() > row_count:
		printerr("[MATCH QUESTION PROMPTER] Warning: ", pairs.size(), " pairs but only ", row_count, \
			" rows. The extra pairs will be lost on the next save!\n")
	
	for index in row_count:
		if index < pairs.size():
			var definition : String = ""
			if not pairs[index].definitions.is_empty():
				definition = pairs[index].definitions[0] # Only one definition per term
			setTerm(index, pairs[index].term)
			setDefinition(index, definition)
		else: # More rows than pairs, leave the rest empty
			setTerm(index, "")
			setDefinition(index, "")

#endregion

#region LOADING

# Fills the prompter with an existing question's data
func loadFromQuestion(question : Question) -> void:
	# Keep the prompt of loaded questions, so saving doesn't overwrite it with the default
	if question.question.strip_edges() != "":
		question_prompt = question.question
	
	syncPairsWithContainers(question.pairs)

#endregion

#region QUESTION SAVING
# Sets the question preview text
func setQuestionPreviewText():
	if associated_creation_modal != null:
		associated_creation_modal.associated_question_item.setQuestionPreview(question_prompt) # Set preview text

# Sets associated question item's question answers to the local answer array
func setQuestionPairs():
	var question_item = associated_creation_modal.getQuestionItem()
	
	if question_item != null:
		question_item.associated_question.pairs = question_pairs

# Sets the local question prompt as the associated question item's question text (prompt)
func setQuestionPrompt():
	var question_item = associated_creation_modal.getQuestionItem()
	
	if question_item != null:
		print("Set prompt to: ", question_prompt)
		question_item.setQuestionText(question_prompt)

# Submits question
func submitQuestion(_print_text : bool = false):
	saveQuestion()

# Compiles all other methods to save all the question data
func saveQuestion():
	syncContainersWithPairs()
	setQuestionPrompt()
	setQuestionPairs()
	printPairs()

	print("[MATCH QUESTION PROMPTER] Saved question data!\n")

#endregion
