require 'fileutils'

class Lyric
  attr_accessor :date, :labels, :text
  attr_reader :filename

  def initialize(lyric_filename)
    @filename = lyric_filename
    @text = ''
    @labels = []
    @date = Time.now
    read_data
    save
    backup_file @filename
  end

  def read_data
    file = new_or_existing_file @filename
    while (line = file.gets)
      line_elements = line.split(' ')
      case line_elements[0]
      when 'date:'
        if line_elements.count == 2
          date_elements = line_elements[1].split(/-|:|,/)
          @date = Time.new(*date_elements)
          puts "date: #{@date}"
        end
      when 'labels:'
        if line_elements.count == 2
          @labels = line_elements[1].split(',')
          puts "labels: #{@labels}"
        end
      else
        @text << line
      end
    end
    file.close
  end

  def save(new_filename = nil)
    @filename = new_filename if new_filename
    Dir.chdir 'lyrics' do
      #File.open(append_time(@filename), 'w') do |file|
      File.open(@filename, 'w') do |file|
        file.puts("date: #{@date.strftime('%Y-%m-%d,%H:%M:%S')}", "labels: #{@labels.join(',')}")
        file.write(@text)
      end
    end
  end

  def delete
    Dir.chdir 'lyrics' do
      File.delete @filename
    end
  end

  def to_s
    @filename
  end

  private

  def new_or_existing_file(filename)
    filepath = File.join('lyrics', filename) #append_time(filename))
    file = nil
    if File.file?(filepath)
      file = File.open(filepath, 'r')
    elsif
      file = File.new(filepath, 'w+')
    end
    file
  end

  def backup_file(filename)
    Dir.chdir 'lyrics' do
      begin
        FileUtils.cp filename, "#{filename}.bak"
      rescue SystemCallError => e
        puts 'Error while backuping file', e.inspect
        raise e
      end
    end
  end
end
