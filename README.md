# MOOSETHMModelCSVs

Note: In order to run the input files required for this study MOOSE must be built on your computer and the THM Module must be activated.
For more information on builiding MOOSE and activating the THM Module go to https://mooseframework.inl.gov/

This repository is organized by fracture diameter and flowrate. For example the folder "5kgs_1m" holds all necessary input and output files for the 5 kgs flowrate and 1m fracture diameter case. Another example would be "5kgs_1m_2fracs", this folder holds all the necessary input and output files for the 5 kg/s, 1m fracture diameter two fracture zone case. For more explanation on these cases please view the powerpoint under the "Powerpoint" folder.

The folder "z5kgs_1m_no_exit_perfs" holds all the input file for the 1m fracture diameter case where exit perforations and both perforations were turned off. The folder "z5kgs_2m_no_exit_perfs" holds all the input file for the 2m fracture diameter case where exit perforations and both perforations were turned off. 

The folder "1fracturemodel" consists of just the 3rd fracture (closest to the toe of the well). There are inlet and exit perforations for this study, however these can be turned back into an Open Hole (no perfs) by setting the perforation flow channel diameter and area to the fracture diameter (2m in this case). This 1 fracture model has results for 5 kg/s and a 2 m fracture diameter. There is a folder in the "1fracturemodel" folder called "Powerpoint," this folder contains a detailed powerpoint explaining all the schematics of the 1 fracture model.

Each folder also contains a Jupyter Notebook that will generate all the plots found in the "plots" folders. Each powerpoint slide with a plot on it has a list of each input and output file that was used in that case.

The folder "Powerpoint" found in the main branch (not in the "1fracturemodel" folder) has a detailed explanation of the model set up and all the results from this study in a neat and organized matter. 

EXODUS Files: All exodus files have been uploaded to the repository and are not in the corresponding folder, however for a more detailed list of which exodus file corresponds to which input file, please refer to the "Powerpoint" folder, as all input and output files for each plot are listed there.

Intern: Benjamin Willis

Mentor: Robert Podgorney
