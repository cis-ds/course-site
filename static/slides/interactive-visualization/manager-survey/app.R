# Load packages -----------------------------------------------------

library(shiny)
library(tidyverse)
library(colorblindr)
library(scales)
library(countrycode)

# Load data ---------------------------------------------------------
manager_survey <- read_csv(
  "data/survey.csv",
  na = c("", "NA"),
  show_col_types = FALSE
)

# perform some basic data cleaning
manager_survey <- manager_survey %>%
  # remove NAs for industry and education
  drop_na(industry, highest_level_of_education_completed) %>%
  # only keep US dollars
  filter(currency == "USD") %>%
  # clean up the industry, country, and education variables
  mutate(
    industry_other = fct_lump_min(industry, min = 100),
    country = countrycode(country, origin = "country.name", destination = "cldr.name.en"),
    highest_level_of_education_completed = fct_relevel(
      highest_level_of_education_completed,
      "High School",
      "Some college",
      "College degree",
      "Master's degree",
      "Professional degree (MD, JD, etc.)",
      "PhD"
    ),
    highest_level_of_education_completed = fct_recode(
      highest_level_of_education_completed,
      "Professional degree" = "Professional degree (MD, JD, etc.)"
    )
  )

# extract all distinct industries as a character vector
industry_choices <- manager_survey %>%
  distinct(industry_other) %>%
  arrange(industry_other) %>%
  pull(industry_other)

# randomly sample 3 starter industries - note we are not using set.seed()
selected_industry_choices <- sample(industry_choices, 3)

# Define UI ---------------------------------------------------------
ui <- fluidPage(
  # add a title panel
  titlePanel(title = "Ask a Manager"),
  # use sidebar layout
  sidebarLayout(
    # create panel for inputs
    sidebarPanel(
      checkboxGroupInput(
        inputId = "industry",
        label = "Select up to 8 industies:",
        choices = industry_choices,
        selected = selected_industry_choices
      ),
    ),
    # create main panel
    mainPanel(
      # use HTML tags to format structure of text
      hr(),
      "Showing only results for those with salaries in USD who have provided
      information on their industry and highest level of education completed.",
      br(), br(),
      # placeholder for selected industries
      textOutput(outputId = "selected_industries"),
      hr(),
      br(),
      # use a tabset for the main content
      tabsetPanel(
        type = "tabs",
        # average salaries plot
        tabPanel(title = "Average salaries", plotOutput(outputId = "avg_salary_plot")),
        # individual salaries tab
        tabPanel(
          title = "Individual salaries",
          # add conditional panel to select observations based on salary
          conditionalPanel(
            condition = "input.industry.length <= 8",
            sliderInput(
              inputId = "ylim",
              label = "Zoom in to salaries between",
              min = 0,
              value = c(0, 1000000),
              max = max(manager_survey$annual_salary),
              width = "100%",
              pre = "$"
            )
          ),
          # plot and table for this panel
          plotOutput(outputId = "indiv_salary_plot", brush = "indiv_salary_brush"),
          tableOutput(outputId = "indiv_salary_table")
        ),
        # show all the data
        tabPanel("Data", DT::dataTableOutput(outputId = "data"))
      )
    )
  )
)

# Define server function --------------------------------------------
server <- function(input, output, session) {
  # generate a character string with the number of selected industries
  output$selected_industries <- reactive({
    paste("You've selected", length(input$industry), "industries.")
  })

  # filter the survey data based on the industry input
  manager_survey_filtered <- reactive({
    manager_survey %>%
      filter(industry_other %in% input$industry)
  })

  # create the data table to be printed on the third panel
  output$data <- DT::renderDataTable({
    manager_survey_filtered() %>%
      select(
        industry,
        job_title,
        annual_salary,
        other_monetary_comp,
        country,
        overall_years_of_professional_experience,
        years_of_experience_in_field,
        highest_level_of_education_completed,
        gender,
        race
      )
  })

  # update the slider input on the second panel based on the new filtered data
  observeEvent(
    eventExpr = input$industry,
    {
      handlerExpr <- updateSliderInput(
        inputId = "ylim",
        min = min(manager_survey_filtered()$annual_salary),
        max = max(manager_survey_filtered()$annual_salary),
        value = c(
          min(manager_survey_filtered()$annual_salary),
          max(manager_survey_filtered()$annual_salary)
        )
      )
    }
  )

  # create a stripchart of raw salaries from filtered data
  output$indiv_salary_plot <- renderPlot({

    # verify only 8 or fewer industries selected for optimal interpretation
    validate(
      need(
        expr = length(input$industry) <= 8,
        message = "Please select a maxiumum of 8 industries."
      )
    )

    # draw the actual plot
    ggplot(
      data = manager_survey_filtered(),
      mapping = aes(
        x = highest_level_of_education_completed,
        y = annual_salary,
        color = industry_other
      )
    ) +
      geom_jitter(size = 2, alpha = 0.6) +
      theme_minimal(base_size = 16) +
      theme(legend.position = "bottom") +
      scale_color_OkabeIto() +
      scale_y_continuous(
        limits = input$ylim,
        labels = label_dollar()
      ) +
      labs(
        x = "Highest level of education completed",
        y = "Annual salary",
        color = "Industry",
        title = "Individual salaries"
      )
  })

  # create table of brushed point observations
  output$indiv_salary_table <- renderTable({
    brushedPoints(df = manager_survey_filtered(), brush = input$indiv_salary_brush)
  })

  # plot average salary per education and industry
  output$avg_salary_plot <- renderPlot({

    # verify only 8 or fewer industries selected for optimal interpretation
    validate(
      need(
        expr = length(input$industry) <= 8,
        message = "Please select a maxiumum of 8 industries."
      )
    )

    # summarize data to get average salary per industry and education
    manager_survey_filtered() %>%
      group_by(industry_other, highest_level_of_education_completed) %>%
      summarise(
        mean_annual_salary = mean(annual_salary, na.rm = TRUE),
        .groups = "drop"
      ) %>%
      # draw the plot
      ggplot(
        mapping = aes(
          x = highest_level_of_education_completed,
          y = mean_annual_salary,
          group = industry_other,
          color = industry_other
        )
      ) +
      geom_line(size = 1) +
      theme_minimal(base_size = 16) +
      theme(legend.position = "bottom") +
      scale_color_OkabeIto() +
      scale_y_continuous(labels = label_dollar()) +
      labs(
        x = "Highest level of education completed",
        y = "Mean annual salary",
        color = "Industry",
        title = "Average salaries"
      )
  })
}

# Create the Shiny app object ---------------------------------------
shinyApp(ui = ui, server = server)
