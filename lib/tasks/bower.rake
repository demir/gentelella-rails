require 'json'

namespace :bower do
  # desc "updates JS version references in README and VERSION files"
  # task :bump do
  #   bump_readme_file
  #   bump_version_file
  # end

  desc "updates javascripts from bower package manager"
  task :update do
    puts `bower install gentelella --save`
  end

  desc "vendors javascripts and stylesheets for rails assets pipeline"
  task :vendor do
    cp_asset "bower_components/gentelella/vendors/autosize/dist/autosize.js"
  end
end

def version_from_bower
  data = JSON.load File.read "bower_components/gentelella/.bower.json"
  data["version"]
end

def gem_path
  File.dirname(File.expand_path(File.join(__FILE__, '..', '..')))
end

def assets_path
  File.join(gem_path, 'assets')
end

def javascripts_path
  File.join(assets_path, 'javascripts')
end

def stylesheets_path
  File.join(assets_path, "stylesheets")
end

def cp_js_assets src, dest
  puts [src, dest].join("\t")
  src_path = src + '/'
  dest_path = File.join(javascripts_path, dest) + '/'
  FileUtils.mkdir_p dest_path
  puts `rsync -rav #{src_path} #{dest_path}`
end

def cp_asset filename, sub_folder = nil, new_name = nil
  base_filename = File.basename(filename)
  assets_folder = base_filename.include?(".js") || base_filename.include?(".coffee") ? "javascripts" : "stylesheets"
  assets_folder = assets_folder + "/#{sub_folder}" if sub_folder
  puts "vendoring " + base_filename
  assets_folder = "assets/#{assets_folder}"
  FileUtils.mkdir_p assets_folder
  FileUtils.cp filename, File.join(assets_folder, (new_name || base_filename))
end

def bump_readme_file
  latest_version = "bundled by this gem is [#{version_from_bower}]"
  lines = File.read('README.md')
  File.open('README.md', 'w'){ |f| f.puts lines.gsub(README_VERSION_REGEXP, latest_version) }
end

def bump_version_file
  version_filename = File.join("lib", "medium-editor", "version.rb")
  latest_version = "MEDIUM_EDITOR_VERSION = '#{version_from_bower}'"
  lines = File.read(version_filename)
  File.open(version_filename, 'w') { |f| f.puts lines.gsub(VERSION_FILE_REGEXP, latest_version) }
end
