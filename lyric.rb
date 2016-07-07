require 'fileutils'

class Lyric
  attr_accessor :date, :labels, :text

  def initialize(lyric_filename)
    @filename = lyric_filename
    backup_file @filename
    @text = ''
    File.open("lyrics/#{@filename}", 'r') do |file|
      while (line = file.gets) do
        next if line.empty?

        line_elements = line.split(' ')
        case line_elements[0]
        when 'date:'
          date_elements = line_elements[1].split(/-|:|,/)
          @date = Time.new(*date_elements)
          puts "date: #{@date}"
        when 'labels:'
          @labels = line_elements[1].split(',')
          puts "labels: #{@labels}"
        else
          @text << line
        end
      end
      p @text
    end
  end

  def save(filename = nil)
    @filename = filename if filename
    Dir.chdir 'lyrics' do
      File.open(@filename, "w") do |file|
        file.puts("date: #{@date.strftime("%Y-%m-%d,%H:%M:%S")}", "labels: #{@labels.join(',')}")
        file.write(@text)
      end
    end
  end

  private

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
