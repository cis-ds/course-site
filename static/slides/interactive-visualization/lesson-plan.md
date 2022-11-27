---
title: "Order of operations for live coding demo"
---

1. Add character string with number of selected industries
    - Easy example of reactivity
    - Retrieves inputs from `input` list object
    - Show how it is stored in the `output` object
1. Filter the survey data based on industry input
    - Uses `reactive()` function again
    - Not stored in `output` since it is not going to be directly included in the app
1. Average salary plot
    - Uses a `render*()` function - another type of reactive function
    - Summarize filtered data which is treated as a function, not a plain object
    - Generate plot and add some formatting - don't need to do it all
    - Incorporate validation test to not generate plot if more than 8 industries are selected
1. Generate data table on third tab
    - Uses `renderDataTable()` function
1. Incorporate strip chart
    - Generate the basic plot
    - Use `input$ylim` to limit the y-axis range
    - Incorporate validation test
1. Update the slider input based on the filtered data
    - `observeEvent()` monitors changes in the specified `input` value, triggers the desired action if it changes
    - `updateSliderInput()` allows us to update the settings for the specified slider input
    - Don't need to assign the output to an object
1. Incorporate brushed points table
    - Brushing allows you to select observations in a plot interactively and use them elsewhere
    - Here

