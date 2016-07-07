require_relative 'string_extensions'

class Song
  attr_reader :name, :lyrics, :ideas, :recordings

  def initialize(song_name)
    @name = song_name
    sections = %w(lyrics ideas recordings)
    song_filename = song_name.to_filename
    song_filename_path = File.join('songs', song_filename)
    Dir.chdir(APP_ROOT) do
      Dir.mkdir('songs') unless File.directory?('songs')
      Dir.mkdir song_filename_path unless File.directory? song_filename_path
      Dir.chdir song_filename_path do
        sections.each do |section|
          instance_variable_set("@#{section}", read_section(section))
        end
      end
    end
  end

  def add_lyrics(lyrics)
    @lyrics << lyrics
  end

  def enter_song_directory
    Dir.chdir "songs/#{@name.to_filename}"
  end

  private

  def read_section(section)
    result = []
    Dir.mkdir(section) unless File.directory?(section)
    Dir.chdir(section) do
      Dir.entries('.').each do |entry|
        result << entry if File.file?(entry) && File.extname(entry) != '.bak' &&
          (section == 'recordings' ? File.extname(entry) == '.wav' : File.size(entry) < 10000) # && entry.is_supported_for(section)
      end
    end
    result
  end
end
