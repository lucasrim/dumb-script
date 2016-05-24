require 'date'

def system_path
  @system_path ||= ENV["PATH"].split(":")
end

def osx_version
  @osx_version ||= %x(sw_vers -productVersion).split(".").slice(0, 2).join(".").chomp
end

def ssystem(command)
  system("#{command} &>/dev/null")
end

def test_command_line_tools_install
  test "Command line tools setup" do
    command_line_tools_install
  end
end

def command_line_tools_install
  case osx_version
  when "10.11"
    return true if ssystem("xcode-select -p")
  when "10.10"
    return true if ssystem("xcode-select -p")
  when "10.9"
    return true if ssystem("pkgutil --pkg-info=com.apple.pkg.DeveloperToolsCLI")
  end

  error "OS X Command Line Tools are not intsalled. Run `xcode-select --install` and follow the instructions."
  
end

def test_rbenv

  return true if ssystem("rbenv -v")
  
end

def test_rbenv_version

  rbenv_global = `rbenv global`.strip

  if rbenv_global == "2.3.0"
    return true
  else
    warnings "Just make it easy for me and use 2.3.0"
  end
  
end

def test_rbenv_install
  test "test rbenv install" do
    test_rbenv && test_rbenv_version
  end
end

def test_homebrew_install
  test "homebrew installed" do
    homebrew_install && homebrew_version
  end
end

def homebrew_install
  return true if ssystem("brew -v")
end

def homebrew_version

  brew_last_updated_on = DateTime.parse(%x(cd $(brew --repository) && git show -s --format=%ci master).chomp).new_offset(0)
  yesterday = DateTime.now.new_offset(0).prev_day

  if brew_last_updated_on > yesterday
    return true
  else
    warnings "Please run 'update brew'"
  end

end


def test_atom_install
  test "Atom installed" do
    atom_install && atom_version
  end
end

def atom_install

  return true if ssystem("which atom")
  error "Atom is not installed"

end

def atom_version
  
  atom_output = `atom -v`

  atom_version_with_name = atom_output.match(/Atom\s+:\s+\d.\d.\d/)[0]

  atom_version_numbers = atom_version_with_name.scan(/\d/)

  first_number = atom_version_numbers[0].to_i

  second_number = atom_version_numbers[1].to_i

  third_number = atom_version_numbers[2].to_i

  return true if first_number >= 1 && second_number >= 7 && third_number >= 2

  error "Please update Atom"
  
end

def test_git_install
  test "git install" do
    git_install
  end
end

def git_install
  return true if ssystem("git --version")
end

def test(string, &block)
  
  @errors = []
  @warnings = []

  result = block.call

  if result
    STDOUT.puts "[OK] #{string}"
  else
    STDERR.puts "[FAILED] #{string}"
  end

  result

  print_errors
  print_warnings
  
end

def print_errors
  @errors.each do |error|
    STDOUT.puts "  ERROR: #{error}"
  end
end

def print_warnings
  @warnings.each do |warning|
    STDOUT.puts " WARNING: #{warning}"
  end
end

def error(string)
  @errors << string
end

def warnings(string)
  @warnings << string
end

def run_tests
  
  test_command_line_tools_install
  test_atom_install
  test_homebrew_install
  test_git_install
  test_rbenv_install
    
end

run_tests
