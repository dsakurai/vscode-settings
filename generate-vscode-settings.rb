#!/usr/bin/env ruby
# Usage:
#   ./generate-vscode-settings.rb
#   ./generate-vscode-settings.rb -d   # demo mode: output to ./demo, no nvim.exe

require "optparse"
require "tmpdir"
require "fileutils"
require "readline"
require "io/console"

SCRIPT_DIR = File.dirname(File.expand_path(__FILE__))

def ask_user(title, items, default: 0)
  index = default

  loop do
    puts title
    items.each_with_index do |item, i|
      marker = i == index ? ">" : " "
      puts "#{marker} #{item}"
    end
    puts "Use Up/Down (or j/k) and Enter."

    key = STDIN.getch
    if key == "\e"
      next1 = STDIN.getch
      next2 = STDIN.getch
      if next1 == "[" && next2 == "A"
        index = (index - 1) % items.length
      elsif next1 == "[" && next2 == "B"
        index = (index + 1) % items.length
      end
    elsif ["\r", "\n"].include?(key)
      return items[index]
    elsif key.downcase == "j"
      index = (index + 1) % items.length
    elsif key.downcase == "k"
      index = (index - 1) % items.length
    elsif key =~ /[1-9]/
      numeric = key.to_i - 1
      return items[numeric]
    end

    puts
  end
end

def prompt_output_dir
  puts(
    "This program can accept existing VSCode settings directory, in which case it will " \
    "back up the current settings and generate a new one by merging in the settings " \
    "favored by this project."
  )
  choice = ask_user(
    "Choose VSCode settings directory:",
    ["Temporary directory", "./", "Custom directory"]
  )

  case choice
  when "Temporary directory"
    Dir.mktmpdir("ansible-vscode-out.")
  when "./"
    "./"
  else
    Readline.readline("Enter path: ", true)&.strip || ""
  end
end

def prompt_nvim_exe
  choice = ask_user(
    "Choose path to nvim.exe:",
    ["None", "scoop default", "Custom path"]
  )

  case choice
  when "None"
    ""
  when "scoop default"
    user_name = Readline.readline('Enter your Windows home directory: C:\Users\ ', true)&.strip || ""
    "C:\\Users\\#{user_name}\\scoop\\shims\\nvim.exe"
  else
    Readline.readline("Enter path: ", true)&.strip || ""
  end
end

output_dir = nil
nvim_exe = nil

OptionParser.new do |opts|
  opts.banner = "Usage: #{$PROGRAM_NAME} [-d]"
  opts.on("-d", "Demo mode: output to ./demo with no nvim.exe") do
    output_dir = File.join(SCRIPT_DIR, "demo")
    nvim_exe = ""
  end
end.parse!

extra_vars = {
  "role" => ask_user(
                "Choose role:",
                ["vscode"]
            )
}

if extra_vars["role"] == "vscode"

    if output_dir.nil?
      output_dir = prompt_output_dir
      nvim_exe = prompt_nvim_exe
    end

    extra_vars = extra_vars.merge({
      "vscode_settings_dir" => output_dir,
      "nvim_exe"            => nvim_exe,
    })
end

puts "Extra vars: #{extra_vars.inspect}"

system(
  "ansible-playbook",
  "--inventory", "localhost,",
  "--connection", "local",
  *extra_vars.flat_map { |k, v| ["--extra-vars", "#{k}=#{v}"] },
  File.join(SCRIPT_DIR, "playbook.yml"),
  exception: true
)
