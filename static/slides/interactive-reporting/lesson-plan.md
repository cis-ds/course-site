---
title: "Order of operations for live coding demo"
---

1. Create basic structure
    - `titlePanel()`
    - `sidebarLayout()`
    - Separate panels using `sidebarPanel()` and `mainPanel()`
1. Locate where content will go
    - Inputs
        - `checkboxGroupInput()`
    - Outputs
        - `textOutput()`
        - Create `tabsetPanel()` to incorporate all output
        - `plotOutput()` (both)
        - `tableOutput()`
        - `DT::dataTableOutput()`
    - Inputs
        - `sliderInput()`
1. Add main panel text and HTML structure

    ```r
      # use HTML tags to format structure of text
      hr(),
      "Showing only results for those with salaries in USD who have provided information
      on their industry and highest level of education completed.",
      br(), br(),
      # placeholder for selected industries
      textOutput(outputId = "selected_industries"),
      hr(),
      br(),
    ```
