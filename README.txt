Open 'HPLCapp.mlapp' file and run the GUI.

Enter the number of initial input variable, give them a name and a value for the LB and UB. 
Set initial number of response variables (currently does nothing) and number of initial experiments.

Clicking Submit generates a Latin hypercube of experiments based on the number of input variables, 
their upper and lower bounds, as well as the number of initial experiments. Each time you click 
submit, the numbers change as different random numbers are used.

When you click 'Start', the program continuously checks a file named ‘HPLC_spectra’ for a new ‘.D’ 
HPLC file to enter. When you drag one in (you can find some at ‘PhD project infomation\Data\Code\MATLAB\HPLC files and code\HPLC Data’
, use the cmtmdHPLC002 file) it loads the file, intergrates the data and shows the spectra. On the 
RHS you can change the wavelength recorded to see all the different types.

Drag the same number of files into the file as you specified in the ‘initial experiments’ 
variable ONE AT A TIME and wait for them to load.

It will output that it’s finished when it is done.

Each time a file is loaded the data gets saved to the file called ‘HPLCData.mat’. If you exit the program and reload the GUI, you can then enter into the load box at the bottom of the page this file path. If you then click load it will bring this data back for you to look at.
Click between the different spectra in the RHS box to change between each one.
