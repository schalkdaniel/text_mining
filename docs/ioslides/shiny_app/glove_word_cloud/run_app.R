# Root to project:
git.root = rprojroot::find_root(rprojroot::is_git_root)

# Set shiny port:
options(shiny.port = 8877)

# Run App:
shiny::runApp(paste0(git.root, '/docs/ioslides/shiny_app/glove_word_cloud'))
