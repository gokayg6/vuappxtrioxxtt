require 'xcodeproj'

project_path = 'VibeU/VibeU.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# Files to add
files_to_add = [
  'VibeU/Services/AdMobManager.swift',
  'VibeU/Services/LanguageManager.swift',
  'VibeU/Services/MatchService.swift',
  'VibeU/Services/DiamondService.swift'
]

target_name = 'VibeU'
target = project.targets.find { |t| t.name == target_name }

if target
  group = project.main_group.find_subpath('VibeU/Services', true)
  
  files_to_add.each do |file_path|
    # Check if file exists in project
    unless project.files.any? { |f| f.path == file_path }
      file_ref = group.new_reference(file_path)
      target.add_file_references([file_ref])
      puts "Added #{file_path} to target #{target_name}"
    else
      puts "#{file_path} already exists in project"
      # Ensure it's in the target
      file_ref = project.files.find { |f| f.path == file_path }
      target.add_file_references([file_ref])
    end
  end
  
  project.save
  puts "Project saved."
else
  puts "Target #{target_name} not found!"
end
