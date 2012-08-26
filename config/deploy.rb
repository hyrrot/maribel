require 'optparse'

set :application, "maribel"
set :temporary_dir, ENV["MARIBEL_TEMPORARY_DIR"] || ("/tmp/" + Date.today.strftime("%Y%m%d"))
set :git_path, ENV["MARIBEL_GIT_PATH"] || "git"
set :repository_path, ENV["MARIBEL_REPOSITORY_PATH"] || abort ("Set MARIBEL_REPOSITORY_PATH envvar")
set :repository_basedir, ENV["MARIBEL_REPOSITORY_BASEDIR"] || ""
set :repository_branch, ENV["MARIBEL_REPOSITORY_BRANCH"] || "master"
set :host_file_list_file, ENV["MAIRBEL_HOST_FILE_LIST_FILE"] || abort ("Set MARIBEL_HOST_FILE_LIST envvar")

# Read host_file_list_file to know which files/dirs to be synched
host_file_list = []

CSV.open("/temp/test.tsv", 'r', "\t") do |row|
  puts row
  next if row[0][0] = "#"
  host_file_list << { :host => row[0], :file => row[1] }
end

role :servers, "your web-server here"                          # Your HTTP server, Apache/etc

# if you want to clean up old releases on each deploy uncomment this:
# after "deploy:restart", "deploy:cleanup"

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

namespace :maribel do
  task :prereq do
    system "mkdir -m #{temporary_dir}/files"
  end

  task :backup do
    # clone repository
    system "#{git_path} clone #{repository_path} #{repositrory_basedir}"
  
    # Login server
    # Download files from webserver
    host_file_list.each do |host_file|
      system("mkdir -p #{temporary_dir}/#{host_file[:host]}/#{File.dirname(host_file[:file]}")
      download host_file[:file], "#{repository_basedir}/#{host_file[:host]}/#{File.dirname(host_file[:file]}" :hosts => [host_file[:host]]
    end
    system "cd #{repositrory_basedir} ; #{git_path} checkout #{repository_branch}"
    system "cd #{repositrory_basedir} ; #{git_path} add ."
    system "cd #{repositrory_basedir} ; #{git_path} commit -m 'Backed up files from hosts.'"
    system "cd #{repositrory_basedir} ; #{git_path} push origin #{repository_branch}"
  end
end

