# TODO: use '@' to refer to favorite

require 'optparse'

LISTFILE = File.join(File.dirname(File.expand_path($0)), 'movelist.dump')

targets = File.exist?(LISTFILE) ? File.open(LISTFILE, 'r:UTF-8') { |f| Marshal.load(f) } : {}

options = {}
optparse = OptionParser.new do |opts|
  opts.banner = 'Usage: moveto.rb [options]'

  opts.on('-l', '--list', 'Display target list') do |l|
    options[:list] = l
  end

  opts.on('-m', '--modify', 'Modify source code') do |m|
    options[:modify] = m
  end

  opts.on('-M', '--Modify', 'Modify source code with gvim') do |m|
    options[:Modify] = m
  end

  opts.on('-p', '--powershell', 'Use powershell cd syntax') do |p|
    options[:powershell] = p
  end

  options[:add] = ""
  opts.on('-a', '--add TARGET', 'Add new target') do |a|
    options[:add] = a
  end

  options[:delete] = ""
  opts.on('-d', '--delete TARGET', 'delete a target') do |d|
    options[:delete] = d
  end
end
optparse.parse!

def display_error(error_message)
  puts error_message
  exit
end

if options[:list]
  targets.each do |name, _path|
    puts '%-12s%s' % [name + ': ', _path.gsub('/', '\\')]
  end
elsif options[:modify]
  puts "vim #{File.expand_path($0)}"
  exit 10
elsif options[:Modify]
  puts "gvim #{File.expand_path($0)}"
  exit 10
elsif !options[:add].empty?
  if targets.include? options[:add]
    display_error "#{options[:add]} is already used"
  end

  targets[options[:add]] = Dir.pwd
  File.open(LISTFILE, 'w:big5') { |f| Marshal.dump(targets, f) }
elsif !options[:delete].empty?
  unless targets.include? options[:delete]
    display_error "#{options[:delete]} is not exist"
  end

  targets.delete options[:delete]
  File.open(LISTFILE, 'w:big5') { |f| Marshal.dump(targets, f) }
elsif ARGV.empty?
  puts optparse
else
  dir = ARGV[0].dup
  from_root = true if dir[0] == '/' or dir[0] == "\\"
  dir.gsub!("\\", '/') if dir.include?("\\")
  dir, *path_abbrs = dir.split('/')
  if from_root
    path_abbrs.unshift dir unless dir.nil?
    dir = '\\'
  end

  if targets.include?(dir)
    dir = targets[dir]
  else
    if File.exist?(dir) # folder or drive
      if dir.end_with?(':')
        dir << '/'
      end
    else
      display_error 'Target not found'
    end
  end

  path, index = "", path_abbrs.size
  until File.exist? path
    path = File.join(dir, *path_abbrs[0, index])
    index -= 1
  end

  index += 1
  unless index == path_abbrs.size
    def get_all_dir(path)
      Dir.entries(path).select do |entry|
        next if %w[. ..].include? entry
        File.directory?(File.join(path, entry))
      end
    end

    def get_abbr_hash(dirs)
      dirs.each_with_object(Hash.new { |h, k| h[k] = [] }) do |dir, abbr_hash|
        abbr = dir.split(/[.\-_ ]+|(?<![A-Z])(?=[A-Z])|(?<=\D)(?=\d)/).map { |s| s[0].downcase }.join
        abbr_hash[abbr] << dir
      end
    end

    def get_path_abbr_index(path_abbr)
      if path_abbr[/\d+\Z/]
        #abbr, abbr_index = path_abbr.split(/(-?\d+\Z)/)
        abbr, abbr_index = path_abbr.split(/\:/) # split by :
        [abbr, abbr_index.to_i]
      else
        [path_abbr, 0]
      end
    end

    until index == path_abbrs.size
      abbr_hash = get_abbr_hash(get_all_dir(path))
      abbr, abbr_index = get_path_abbr_index(path_abbrs[index])
      
      if abbr_hash.include?(abbr)
        begin
          path = File.join(path, abbr_hash[abbr][abbr_index])
        rescue
          #display_error 'Wrong index'
          break
        end
      elsif abbr_hash.values.flatten.include?(path_abbrs[index])
        path = File.join(path, path_abbrs[index])
      else
        break
      end

      index += 1
    end
  end

  path.gsub!('/', "\\")
  if options[:powershell]
    puts %[cd "#{path}"]
  else
    puts %[cd /D "#{path}"]
  end
  exit 10
end
