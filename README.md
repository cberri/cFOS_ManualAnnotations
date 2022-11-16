## Fos  Protein and *c-fos* mRNA Manual Counts for Quanty-cFOS.ijm  Validation

This repository contains the *ImageJ/Fiji GT_Annotations.ijm* tool and representative Fos/*c-fos* stained images that can be used to validate the Quanty-cFOS automated counting tool for Fos protein and *c-fos* mRNA



#### How to run the *GT-Annotations_v0.ijm* tool

The user can open the *GT_Annotations.ijm* by dragging and dropping the file on the main ImageJ/Fiji window. This opens the ImageJ/Fiji interpreter that can be used to run the code. Alternatively, you can copy the file in the ImageJ/Fiji plugin directory and run the tool using the ImageJ/Fiji GUI (e.g.: `C:\Users\XXX\XXX\XXX\fiji-win64\Fiji.app\plugins`). Please, restart ImageJ/Fiji after this operation

<u>Step-by-Step Instructions:</u>

1. Hit the **Run** button or go to plugin and select *GT-Annotations_v0*
2. Select the input file to process from the **SampleImages** folder
3. A dialog box will pop up
4. Enter your **fist name** and press **ok**
5. Use the **left mouse** button to mark positive cells and the **right mouse** button to label negative cells. The cells are marked in 2 different colors depending on the image lookup table
6. To finish the annotation step hit the **shift** key on your keyboard
7. The dialog box will pop up again
8. To end the annotation task check the box **End annotating** and uncheck the box **Start annotating**. If there is a need in annotating a different channel on the input image the user can start a new round of annotations. In this case the ID changes of one unit for later postprocessing



The **output folder** is saved in the input folder and it contains:

1. The image with the overlaid labels
2. The ROIs added to the RoiManager
3. A csv file with the annotation ID, the xy coordinates of the center of mass, the class index (1: positive, 3: negative) and the class name (cFOS positive or negative)
4. A Log file



Please let me know if you have any suggestion on how to improve the tool or if you think some functionalities are missing

