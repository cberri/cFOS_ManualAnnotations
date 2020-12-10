/*
 * Project Generate GT
 * 
 * Developed by Dr. Carlo A. Beretta 
 * Math Clinic CellNetworks, University of Heidelberg
 * Email: carlo.beretta@bioquant.uni-heidelberg.de
 * Web: http://math-clinic.bioquant.uni-heidelberg.de
 * Tel.: +49 (0) 6221 54 51435
 * 
 * Created: 2020/12/09
 * Last update: 2020/12/09
 * 
 * NB: 
 * 1. POSITIVE is annotated by left click 
 * 2. NEGATIVE is annotated by right click
 * 3. SHIFT stop the current annoations and ask the user if wants to start with a new one or end with the experiment. 
 * 4. The results are saved in an output folder inside the input image path
 *
 */

// 1. Close all the open images before starting the macro
function CloseAllWindows() {
	
	while(nImages > 0) {
		selectImage(nImages);
		close();
		
	}
	
}

// 2. Open B&C window and thershold window
function OpenBCWindow() {

	if (!isOpen("B&C")) {
		
		run("Brightness/Contrast...");

	} 
	
	if (!isOpen("Threshold")) {
	
		run("Threshold...");
					
	}
	
}

// 3. Close B&C window
function CloseBCWindow() {

	if (isOpen("B&C")) {
		
		selectWindow("B&C"); 
		run("Close");

	}
	
}

// 4. Close the ROI Manager 
function CloseROIsManager() {
	
	if (isOpen("ROI Manager")) {
		
		selectWindow("ROI Manager");
     	run("Close");
     	
     } 
     
}

// 5. Open the ROI Manager
function OpenROIsManager() {
	
	if (!isOpen("ROI Manager")) {
		
		run("ROI Manager...");
		
	} else {

		if (roiManager("count") == 0) {

			print("Warning! ROI Manager is already open and it is empty");
			wait(3000);
			print("\\Clear");

		} else {

			print("Warning! ROI Manager is already open and contains " + roiManager("count") + " ROIs");
			print("The ROIs will be deleted!");
			roiManager("reset");
			wait(3000);
			print("\\Clear");
			
		}
		
	}
	
}

// 6. Save and close Log window
function CloseLogWindow(analysisPath) {
	
	if (isOpen("Log")) {
		
		selectWindow("Log");
		saveAs("Text", analysisPath + "Log.csv"); 
		run("Close");
		
	} else {

		print("Log window has not been found");
		
	}
	
}

// 7. Update the annotation table when the file is processed
function OutputTable(analysisPath, title) {
	
	col = newArray;
	Table.create("Annotation Results_" + title);
	Table.setColumn("% Id", col);
	Table.setColumn("% X", col);
	Table.setColumn("% Y", col);
	Table.setColumn("% Class Index", col);
	Table.setColumn("% Class", col);
	Table.update;

	outputLogTable = getInfo("log");
 	print("[Annotation Results_" + title + "]", outputLogTable);

	// Save the annotation table
 	selectWindow("Annotation Results_" + title);
	saveAs("Text",  analysisPath + title + ".csv");
	selectWindow("Annotation Results_" + title);
	run("Close");

}

// 8. Input dialog box user setting
function InputUserSettingParameters(id, title) {

	width=600; height=512;
	experimentTitle = title;
	userName = "First Name";
	objID = id;

	startAnnotation = true;
	endAnnotation = false;
	makeCompoiste = false;
	
	Dialog.create("Ground Truth Annotation Setting");
	Dialog.addString("Experiment Name", experimentTitle, 20);
	Dialog.addString("User Name", userName, 20);
	Dialog.addNumber("ID", objID, 0, 8, "");
	
	Dialog.addCheckbox("Start Annotating", startAnnotation);
	Dialog.addCheckbox("End Annotating", endAnnotation);
	Dialog.addToSameRow();
	Dialog.addCheckbox("Create Composite", makeCompoiste);
	Dialog.addMessage("____________________________________________________________________________");
	Dialog.addMessage("1. Positive cFOS Annotation (Class Id 1): LEFT MOUSE CLICK", 11, "#001090");
	Dialog.addMessage("2. Negative cFOS Annotation (Class Id 3): RIGHT MOUSE CLICK", 11, "#001090");
	Dialog.addMessage("3. End annotating: Press SHIFT", 11, "#001090");
  	Dialog.show();

	experimentTitle = Dialog.getString();
	userName = Dialog.getString();
	objID = Dialog.getNumber(); 
	startAnnotation = Dialog.getCheckbox();
	endAnnotation = Dialog.getCheckbox();
	makeCompoiste = Dialog.getCheckbox();
	title = experimentTitle + "_" + userName;

	inputParameters = newArray(objID, startAnnotation, endAnnotation, makeCompoiste, title);
	return inputParameters;
	
}

// 9. Get annotation coordinates by clicking
function MouseAnnotation(objID, frames) {

	// Default tool
	setTool("point");

	// Width and height of the image in pixel
	width = getWidth();
	height = getHeight();

	setOption("DisablePopupMenu", true);
	getPixelSize(unit, pixelWidth, pixelHeight);
	leftClick = 16;
	rightClick = 4;
	x2=-1; y2=-1; flags2=-1;
	getCursorLoc(x, y, z, flags);

	while (!isKeyDown("shift")) {

		count = roiManager("count");
		getCursorLoc(x, y, z, flags);

    	if (x != x2 || y != y2 || flags != flags2) {

			// brasher diamiter
			if (width <= 512 && height <= 512) {

				d = 15;
					
			} else if (width > 512 && height > 512) {

				d = 20;

			}
			
     		// Right Mouse click
        	if (flags & leftClick != 0) {

        		r = d /2;
				wait(50);			
				makePoint(x, y, "small magenta cross");
				getCursorLoc(x, y, z, flags);	
            	Stack.getPosition(channel, slice, frame);

            	// Mouve to the next time point	
            	makeOval(x-r, y-r, d, d);
				run("Set...", "value=100");
            
            	// Add to the ROI Manager
            	roiManager("Add");
            	roiManager("Set Color", "green"); 
            	roiManager("select", count);
            	roiManager("rename", "cFOS Positive_" + x + "-" + y + "-" + z);
            	roiManager("deselect");

            	// Output
            	print(id + "\t" + x + "\t" + y  +"\t"  + 3 + "\t" + "cFOS Positive" + "\t");	
            			
     		// Left Mouse Clikc
     		} else if (flags & rightClick != 0) {

        		r = d /2;
				wait(50);
				makePoint(x, y, "small cyan cross");
        		getCursorLoc(x, y, z, flags);	
        		Stack.getPosition(channel, slice, frame);	

        		// Mouve to the next time point
				makeOval(x-r, y-r, d, d);
				run("Set...", "value=25");

           		// Add to the ROI Manager
            	roiManager("Add");
            	roiManager("Set Color", "red"); 
            	roiManager("select", count);
            	roiManager("rename", "cFOS Negative_" + x + "-" + y + "-" + z);
            	roiManager("deselect");

				// Output
        		print(id + "\t" + x + "\t" + y  +"\t"  + 1 + "\t" + "cFOS Negative" + "\t");

     		}
        		
     	}

		x2=x; y2=y; flags2=flags;
                     
	}

	setOption("DisablePopupMenu", false);
   
} 

// 10. Save the ROIs
function SaveROIs(id, analysisPath, title) {

	// Save the ROIs for further analsysis 
	roiManager("Save", analysisPath + title +"_Annotation_0" + id + ".zip"); 																								 

	// Clear the ROI Manager and remove selections
	roiManager("reset");
	run("Select None");
	
}

// GT Annotation
macro GroudTruth_Manual_Annotations {

	// Start up functions 
	CloseAllWindows();
	OpenBCWindow();
	OpenROIsManager();

	// Choose the input image to process
	open();
	Stack.getDimensions(width, height, channels, slices, frames);
	inputTitle = getTitle();

	// Only 8 bits supported for now
	if (bitDepth() != 8) {
		
		resetMinAndMax();
		run("8-bit");
		
	}

	// Remove file extention
	dotIndex = lastIndexOf(inputTitle, ".");
	title = substring(inputTitle, 0, dotIndex);

	// Output directory
	dirOut = File.directory();

	// Create the output directory
	analysisPath = dirOut + "GT_Results_" + title + File.separator;
	File.makeDirectory(analysisPath);

	// Input setting
	id = 1;
	inputParameters = InputUserSettingParameters(id, title);
	objID = inputParameters[0];
	startAnnotation = inputParameters[1];
	endAnnotation = inputParameters[2];
	makeCompoiste = inputParameters[3];
	title = inputParameters[4];

	while (startAnnotation == true) {

		if (makeCompoiste == true && channels > 1) {

			Stack.setDisplayMode("composite");
			
		} else if (makeCompoiste == false && channels > 1) {
			
			Stack.setDisplayMode("color");
			
		}

		// Press shift when you have done or you want to count cells in a different area
		while(!isKeyDown("shift")) {
		
			selectImage(inputTitle);
			MouseAnnotation(objID, frames);
			startAnnotation == true;
			print("\n");
		
		}
        
		// Reset time
		Stack.setPosition(1, 1, 1);

		// Increase the track id of 1 x each start track
		id += 1;
		
		// Show the dialog box only when a new annoation has to be done
		inputParameters = InputUserSettingParameters(id, title);
		objID = inputParameters[0];
		startAnnotation = inputParameters[1];
		endAnnotation = inputParameters[2];
		makeCompoiste = inputParameters[3];
		//title = inputParameters[4];
	
		if (startAnnotation == false && endAnnotation == true) {

			startAnnotation == false;
			
		} else if (startAnnotation == false && endAnnotation == false) {

			print("Wrong Input! You must choose to start a new annotation or end the annotation query!");
			startAnnotation == true;

			// Show the dialog box only when a new set of annotation needs to be add
			inputParameters = InputUserSettingParameters(id, title);
			objID = inputParameters[0];
			startAnnotation = inputParameters[1];
			endAnnotation = inputParameters[2];
			makeCompoiste = inputParameters[3];
			title = inputParameters[4];
		
		}
	
	}

	// Copy the Log windiow in the result table
	SaveROIs(id, analysisPath, title);
	OutputTable(analysisPath, title);

	// Save the overlay image
	selectImage(inputTitle);
	saveAs("tiff", analysisPath + "OverlayGT_Annotation_" + title);
	inputTitle = getTitle();
	close(inputTitle);

	// End functions
	CloseLogWindow(analysisPath);
	CloseAllWindows();
	CloseROIsManager();
	CloseBCWindow();
	

}