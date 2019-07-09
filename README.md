# Analyze-naive-and-pregnant-females-responses
analyzing AOB neurons responses for chemo-sensory stimuli  in naive and mated females

The main function is "analyze_bruce_urine_responses". In this function, the analyzes to perform, parameters to define response, and other criterions are defined. 
The main function calls prepare_data_for_michals_analysis where the data-struct is created by the criterions defined in the main function.
The function "plot_units_for_manual_selection" is going over the significant responding units, plot (with the "plot_unit" function) the raster and psth of the units (to all stimuli) and updates the units excel file with the score and response-time selected for each unit that was presented. 
