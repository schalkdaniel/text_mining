fluidPage(
  # Application title
  titlePanel("GloVe: Most Similar Word App"),
  withMathJax(),
  # Custom css:
  theme = 'style.css',
  
  sidebarLayout(
    # Sidebar with a slider and selection inputs
    sidebarPanel(
      textInput(inputId = "my.word", label = "", value = "university")
      # actionButton("update", "Change")
    ),
    
    # Show Word Cloud
    mainPanel(
      plotOutput("plot")
    )
  )
)