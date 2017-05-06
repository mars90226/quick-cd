# TODO: use '@' to refer to favorite

require 'optparse'
require 'abbrev'

def display_error(error_message)
  puts error_message
  exit
end

def execute_command(command)
  puts command
  exit 10
end

class PathCalculator
  DIR_ABBR_PATTERN = /[.\-_ ]+|(?<![A-Z])(?=[A-Z])|(?<=\D)(?=\d)/

  def initialize(targets)
    @targets = targets
  end

  def parse_dir_and_path_abbrs(dir)
    from_root = true if dir[0] == '/' or dir[0] == '\\'
    dir.gsub!('\\', '/') if dir.include?('\\')
    dir, *path_abbrs = dir.split('/')
    if from_root
      path_abbrs.unshift dir if dir
      dir = '\\'
    end

    [dir, path_abbrs]
  end

  def get_all_dir(path)
    Dir.entries(path).select do |entry|
      next if %w[. ..].include? entry
      File.directory?(File.join(path, entry))
    end
  end

  def get_abbr_hash(dirs)
    dirs.each_with_object(Hash.new { |h, k| h[k] = [] }) do |dir, abbr_hash|
      abbr = dir.split(DIR_ABBR_PATTERN).reject { |s| s.empty? }.map { |s| s[0].downcase }.join
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

  def calculate(dir)
    dir, path_abbrs = parse_dir_and_path_abbrs(dir)

    if @targets.include?(dir)
      dir = @targets[dir]
    else
      if File.exist?(dir) # folder or drive
        dir << '/' if dir.end_with?(':') # drive
      else
        display_error 'Target not found'
      end
    end

    path, index = "", path_abbrs.size

    # Remove unexist parts of path
    until File.exist? path
      path = File.join(dir, *path_abbrs[0, index])
      index -= 1
    end

    index += 1
    unless index == path_abbrs.size

      # Step forward to the path
      until index == path_abbrs.size
        # Get list of abbreviation of directories
        abbr_hash = get_abbr_hash(get_all_dir(path))
        Abbrev.abbrev(abbr_hash.keys).each do |key, value|
          abbr_hash[key] = abbr_hash[value]
        end
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
    path
  end
end

class QuickMove
  ABSOLUTE_PATH = File.expand_path($0)
  LISTFILE = File.join(File.dirname(ABSOLUTE_PATH), 'movelist.dump')

  def initialize
    @targets = File.exist?(LISTFILE) ? load_targets : {}
  end

  def load_targets
    File.open(LISTFILE, 'r:big5') { |file| Marshal.load(file) }
  end

  def save_targets(targets)
    File.open(LISTFILE, 'w:big5') { |file| Marshal.dump(targets, file) }
  end

  def parse(args)

    @options = {}
    optparse = OptionParser.new do |opts|
      opts.banner = 'Usage: moveto.rb [options]'

      opts.on('-l', '--list', 'Display target list') do |l|
        @options[:list] = l
      end

      opts.on('-m', '--modify', 'Modify source code') do |m|
        @options[:modify] = m
      end

      opts.on('-M', '--Modify', 'Modify source code with gvim') do |m|
        @options[:Modify] = m
      end

      opts.on('-p', '--powershell', 'Use powershell cd syntax') do |p|
        @options[:powershell] = p
      end

      opts.on('-a', '--add TARGET', 'Add new target') do |a|
        @options[:add] = a
      end

      opts.on('-d', '--delete TARGET', 'delete a target') do |d|
        @options[:delete] = d
      end
    end
    optparse.parse!

    @args = Marshal.load(Marshal.dump(args))
  end

  def execute
    if @options[:list]
      @targets.each do |name, _path|
        puts '%-12s%s' % [name + ': ', _path.gsub('/', '\\')]
      end
    elsif @options[:modify]
      execute_command "vim #{ABSOLUTE_PATH}"
    elsif @options[:Modify]
      execute_command "gvim #{ABSOLUTE_PATH}"
    elsif @options[:add]
      if @targets.include? @options[:add]
        display_error "#{@options[:add]} is already used"
      end

      @targets[@options[:add]] = Dir.pwd
      save_targets(@targets)
    elsif @options[:delete]
      unless @targets.include? @options[:delete]
        display_error "#{@options[:delete]} is not exist"
      end

      @targets.delete @options[:delete]
      save_targets(@targets)
    elsif @args.empty?
      display_error optparse
    else
      path = PathCalculator.new(@targets).calculate(@args[0])

      if @options[:powershell]
        execute_command %[cd "#{path}"]
      else
        execute_command %[cd /D "#{path}"]
      end
    end
  end
end

if $0 == __FILE__
  quick_move = QuickMove.new
  quick_move.parse(ARGV)
  quick_move.execute
end
