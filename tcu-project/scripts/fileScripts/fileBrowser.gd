class_name FileBrowser
extends Node

func openFileBrowserWindow() -> String:
	var output : Array = []
	
	var ps_script : String = "
		[System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms'); 
		$objForm = New-Object System.Windows.Forms.OpenFileDialog; 
		$objForm.Filter = 'CSV Files (*.csv)|*.csv'; 
		$objForm.ShowDialog(); $objForm.FileName
	" # Custom windows powershell script to open the file browser that detects '.csv' files

	# Executes hidden powerShell command line call to pull paths
	OS.execute("powershell", ["-Command", ps_script], output)

	if output.size() > 0:
		var lines = output[0].split("\n") # Separate first
		
		for line in lines: # Iterate to find path
			var cleaned_line : String = line.strip_edges()
			
			if cleaned_line.ends_with(".csv"):
				print("[FILE BROWSER] Cleaned result: " + cleaned_line + ".\n")
				
				return cleaned_line  # Path found, return it
	return ""

func onFileSelected(file_path : String = "") -> String:
	print("[FILE BROWSER SIGNAL] File name: " + file_path + ".\n")
	
	return file_path # Returns file path so FileLoader can handle it
