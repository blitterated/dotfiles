Pry.config.editor = "vim"
Pry.config.editor = proc { |file, line| "vim +#{line} #{file}" }
