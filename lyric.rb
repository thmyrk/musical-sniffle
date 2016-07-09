require 'fileutils'

class Lyric
  attr_accessor :date, :labels, :text
  attr_reader :filename

  def initialize(lyric_filename)
    @filename = lyric_filename
    @text = ''

    file = File.file?("lyrics/#{@filename}") ? File.open("lyrics/#{@filename}", 'r')
                                             : File.new("lyrics/#{@filename}", 'w+')
    backup_file @filename
    while (line = file.gets) do
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
    file.close
    @labels ||= []
    @date ||= Time.now
  end

  def save(filename = nil)
    @filename = filename if filename
    Dir.chdir 'lyrics' do
      File.open(@filename, 'w') do |file|
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
