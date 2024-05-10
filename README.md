# HPLCMethodOptimisationGUI

## The GUI

![image](https://github.com/Bourne-Group/HPLCMethodOptimisationGUI/assets/74144152/ff873406-96b8-4d48-8ed0-f1ead7d0112d)

HPLC method optimization software has been written that incorporates Bayesian optimization algorithms to autonomously optimize for chromatogram quality. The software handled every element of the method development process: from method creation and execution to data analysis and optimization of method conditions. This makes the system ‘closed loop’ which removes the need for user input during the optimization process. Code was written in MATLAB and ChemStation macros to automate all parts of the HPLC method optimization process, including:
- The writing and execution of HPLC methods.
- Reading chromatogram data and performing analysis to extract the chromatogram quality.
- Machine learning algorithms, specifically Bayesian optimization, to automate the method development.
- A graphical user interface (GUI) to provide a user-friendly application for the user to define parameters for the optimiza-tion and analyse the data.

To make the autonomous HPLC method development system user friendly, a graphical user interface (GUI) using MATLAB’s built-in app designer was created, shown in Figure 1. This software built in all the parameters required for the optimization to take place, including:
- The design space, or ‘HPLC space’ for the optimization, which could be modified by selecting the “Configure input vari-ables” button. Here, different variables could be set either to constant values, or to be optimized with upper and lower boundaries to be defined. The more variables that are selected to be optimized, the more dimensionality is added to the optimization and the longer it will take to optimize. Figure 3 shows the how the input variables are configured when the “Configure input variables” button is pressed.
- Selection of an optimization algorithm from the “Algorithm” drop down box, as well as the chosen objective functions. If the algorithm is single objective such as BOAEI then only one objective function can be selected. If the algorithm is multi-objective such at TS-EMO then multiple objectives can be selected.
- Extra parameter data including:
  - Setting the initial number of experiments to run. The initial experiments generated are based off a LHS design, which is then scaled between the lower and upper bounds defined by each variable.
  - Setting the HPLC directory where the chromatogram data is stored to be read by the app when the HPLC methods finish.
  - Equilibration time to denote how long the app should wait after setting the defined HPLC method conditions before starting the method.
  - The type of detection method used for the chromatograms, either using the DAD detector to select a specific wave-length to monitor (given in the settings the DAD has been enabled for that wavelength range), or a specific VWD channel set in the ChemStation software that needs to be setup before.
o	The option to use built in peak detection with a community made gaussian peak picking function along with its as-sociated parameters, or to use the built in ChemStation detection which the user must predefine in the HPLC method beforehand and configure to save the data as a CSV after the method has finished.
- A Data visualisation tab shown in Figure 2 to show the chromatograms processed when the slider is set to 1 on the left-hand side, or to plot the input and response data in up to five dimensions (x, y, z axis as well as colour and dot size) when the slider is set to 2 on the right-hand side. This allows for most of the data processing to be done by the user within the app.
-	The ability to load data from a previous save to either continue an optimization or for data analysis using the “Load” but-ton.  When the apply button is pressed all data is saved in a folder called “Results” with the name defined by the user in the “Data file name” text box.
-	A reprocess button that allows the user to re-process the objective function results when the built in peak picking parame-ters have been modified, or if changes to the objective function code are made.
-	Start and pause buttons for the optimization. A counter is available labelled “Number of experiments” to define how many optimization algorithm experiments the user wants to run after the initial conditions has finished. Optimization will start automatically if the “Auto start” box is checked.

 ![image](https://github.com/Bourne-Group/HPLCMethodOptimisationGUI/assets/74144152/203013cb-0774-4a9d-a690-2fda16eb8faf)
Figure S1: The HPLC optimization GUI inputs tab.

![image](https://github.com/Bourne-Group/HPLCMethodOptimisationGUI/assets/74144152/7bb0ae29-a522-411d-9c82-bcdc89fd85aa)
Figure S2: The HPLC optimization GUI Data visualisation tab. 

![image](https://github.com/Bourne-Group/HPLCMethodOptimisationGUI/assets/74144152/b6f80f08-afaa-4e91-8dd0-a5a56569a562)
Figure S3: GUI that allows the user to configure the input variables to define the design space for the HPLC method optimization.

The user interface breaks down a HPLC optimization into three main steps. The first step involves defining the design space, optimization algorithm, objective functions, peak detection parameters, wavelength monitoring and other experimental parameters. Clicking the “Apply” button once these parameters are set will save the file so that data can be accessed later (via the “Load” button option). It will also generate all the initial experiments to be run. Step 2 involves running each of the generated initial condition HPLC methods. Clicking start will begin the automated closed loop process of setting the HPLC method, running the method and analysing the chromatogram data to obtain the objective function responses. These initial conditions provide a scan of the design space which is used in step three as a starting point for the optimization algorithm. Step 3 will start the optimization, incorporating the selected optimization algorithm to decide the next conditions to be run. The results are updated each time a method has finished, and this data can visualized in the “Data visualisation” tab show in Figure S2.

## Bayesian optimization

![image](https://github.com/Bourne-Group/HPLCMethodOptimisationGUI/assets/74144152/e09fb1e4-7c46-44a8-9397-280c51616e8a)
Figure S4: Flow chart detailing how a closed loop-optimization of HPLC methods can be achieved.

Both single and multi-objective Bayesian optimization algorithms were used to optimize HPLC method conditions. These algorithms however require suitable objective functions to be defined that quantify the overall quality of the chromatograms. The key parameters in this work that were used to define chromatogram quality were:
- The time the last peak elutes. This corresponds to the method time. The shorter the method time the more efficient the method.
- The critical resolution (RsCrit), which is the smallest measured resolution between any consecutive pair of peaks. Peaks need to be close enough to ensure that the method time is minimized but not too close to prevent overlap of peaks.
- The number of peaks detected. Maximising the number of peaks will help the algorithm to separate all the different com-ponents in the analyte.

By looking at, or a combination of, these different responses, the overall chromatogram quality can be calculated, and can there-fore be used as an objective(s) for the chosen optimization algorithm. Four different objective functions were created for optimiza-tion. Each one coded required a table containing information about each peak including its retention time, height, and width at half height. Other information about peak cutoffs was also required. 
For the single objective Bayesian optimization algorithm BOAEI 2, a weighted objective function was created that combined the time the last peak eluted, the critical resolution and the number of peaks chromatogram quality factors into one single objective. Code written to do this is available on a GitHub repository under the file name “responceCombFunc1.m”. For the multi-objective Bayesian optimization algorithm TS-EMO3, 4, the time the last peak eluted, the critical resolution and the number of peaks chro-matogram quality factors were written as three separate objective functions under the name “responceMaxTime.m”, “responceR-scrit.m” and “responceNumbPeaks.m” respectively.

## Automated HPLC method transfer and execution using ChemStation macros

One step in the automation of HPLC method development involves both autonomously writing and executing HPLC methods to a HPLC system. ChemStation5 is used to create and run HPLC methods. The software works by sending commands to the HPLC hardware via serial communication. To access and use these serial communication commands to control the HPLC hardware di-rectly was troublesome due to intellectual property issues and that they were not publicly available. This meant that another meth-od of communication with the HPLC hardware was required. Application program interfaces are also available from companies, which allow for code to be used to communicate with HPLCs and write methods. However generally these can be costly, and so were not suitable for use in this project as a proof of concept for HPLC method optimization.
After further investigation, it was noted that ChemStation offered the ability for macros to be coded. A macro is code that can be used to automate tasks within a software package. Using guides provided by Agilent that were freely available online, macros were written that could modify HPLC method parameters and execute the method. This used Excel as a database, so that desired method conditions could be written to Excel before. Then using a Chemstation macro to read the Excel document, the HPLC method could be automatically modified accordingly before running the method. The macros had the ability to set up a Dynamic Data Link (DDL) with excel. This required a pre-written and open version of excel to transfer data dynamically between excel and ChemStation, details of which can be found in the macro programming guide written by Agilent. This enabled data transfer be-tween software applications as well as autonomous control of the HPLC hardware. The macros written to automate HPLC method writing are available in the GitHub repository in the file “MACROS”.
Three macro function files were written to achieve automation:
- editMeth.MAC– When executed this macro would read and extract HPLC method data from the excel file containing the method information using a DDL. Different cells in the excel document would correspond to different method parame-ters, such as the timetable for the HPLC method, column temperature and injection volume. 
- FullRun.MAC – This macro is executed in the command line of the ChemStation software by some external MATLAB code using a mouse clicker when a method is ready to be run. It ensures that the HPLC is in the “Ready” state, before ex-ecuting the EditMeth macro described previously. It also creates a DDL with the method excel file to see if the method is ready to be run and obtain a equilibration time. The macro then waits for a set equilibration time before starting the HPLC method.
- updateExcel.MAC – Chemstation has a feature for a macro to be run automatically when a method has finished, defined as a post-run macro. This final macro is used as a post-run macro, and creates a DDL with the excel method file to write the method name and to notify to external MATLAB script that the method has finished running.

A summary of each of the events for HPLC method writing and execution is explained below.
- MATLAB generates a new HPLC method and it is written to an Excel file which acts as a sever for the current HPLC method information to be run.
- The MATLAB software uses an automated mouse and keyboard program to start the method execution macro (Full-Run.MAC), by entering the macro command into command prompt in ChemStation and pressing enter to execute it.
- The method execution macro begins to switch on the equipment, check for equipment ready state and execute the Edit-Meth.MAC macro, which consequently will modify the HPLC method information based on what is stored in the method Excel file using a DDL. The macro then waits for an equilibration period before it starts the HPLC method.
- Once the HPLC method has finished running, the post-run macro is executed to update the method excel file with the HPLC file name so that it can be read by MATLAB for the optimization process.

## Automated data analysis

Once a HPLC file has finished running, important information from the chromatogram needed to be extracted so that it could be fed into the optimization algorithm. For this work, the number of peaks, the critical resolution, and the time the last peak eluted from the chromatogram were extracted from the chromatogram. 
Chemstation can automatically analyse chromatographic data and export it to a CSV file for analysis. However, it is not able to export the raw time-intensity data to a CSV automatically after the HPLC method was run. Therefore, some code was required to read the ChemStation ‘.ch’ files, which are specific to ChemStation to obtain this information. Code written by Dillon et al.6 was used to convert the raw Agilent ‘.ch’ files into a readable time intensity data array. Figure S5 shows a flow chart of how raw data is processed into objective responses that can then be fed into the optimization algorithms. 

![image](https://github.com/Bourne-Group/HPLCMethodOptimisationGUI/assets/74144152/12a1a858-d26f-421a-bd3e-a91847f4453f)
 
Figure S5: A flow chart detailing the process in which the raw chromatogram data file is processed into objective function re-sponses that describe the quality of the chromatogram.
Peak picking and the associated parameters were extracted using two methods. Firstly, the peak information in the chromatogram was identified using an community made automated gaussian peak fitting algorithm written by O'Haver et al.7, which allowed for a time-intensity array to be passed into a function and outputted peak information in the form of a table. A function named “au-tofindpeaks.m” was used to obtain this information, and required the following parameters for peak detection:
- Slope Threshold : Peak detection is achieved by looking for downwards zero-crossings in the first derivative. Slopes that exceed the Slope threshold will be detected and so larger values will result in loss of smaller features.
- Amplitude threshold: Ignores peaks below this amplitude value.
- Smooth width: the width of the smoothed peaks before detection, where a larger number will result in ignoring narrower peaks 
- Peak group: The number of data points around the top part of the peak which taken for measurement to fit the peak.
- Smooth type: The type of smoothing algorithm performed on the data, which choices of rectangular (sliding-average), triangular (2 passes of sliding-average) or pseudo-gaussian (3 passes of sliding-average)

By modifying these parameters, the sensitivity of peak detection could be modified to ensure all relevant peaks in the chromato-gram were detected and modelled correctly to give accurate peak information.
ChemStation also has built in peak detection with parameters that can be modified, like the one explained above. By modifying the data acquisition method and selecting the setting that exports it to CSV after the method has finished, this approach can be used to automate the data processing instead of using the community made algorithm. This functionality has been built into the application shared within this work, however using ChemStation’s built in peak detection was not used for this work.
