# Root to project:
git.root = rprojroot::find_root(rprojroot::is_git_root)

# Set shiny port:
options(shiny.port = 8877)

# Run App:
shiny::runApp(paste0(git.root, '/docs/ioslides/shiny_app/glove_word_cloud'))

# Run in bash:
chrome file:///C:/Users/schal/OneDrive/github_repos/text_mining/docs/ioslides/text.html#1
