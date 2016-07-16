require_relative 'string_extensions'
require_relative 'lyric'
require_relative 'idea'
require_relative 'recording'

# Lyrics, ideas and recordings are not objects of appropriate
# classes, but filenames! Reason for that is that shoes listbox operates only
# on strings. It's impossible to read objects from it
# Song represents current song and has a list of lyrics,
# ideas and recordings read from filesystem on song load
class Song

  attr_reader :name, :lyrics, :ideas, :recordings

  def initialize(song_name)
    @name = song_name
    sections = %w(lyrics ideas recordings)
    song_filename = @name.to_filename
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

  def add_section_element(section, filename)
    instance_variable_get("@#{section}") << filename
  end

  def remove_section_element(section, filename)
    instance_variable_get("@#{section}").delete filename
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
        if File.file?(entry) && File.extname(entry) != '.bak' &&
          (section == 'recordings' ? File.extname(entry) == '.wav' : File.size(entry) < 10000) # && entry.is_supported_for(section)
          #file = cut_time(entry)
          result << entry
        end
      end
    end
    result
  end
end
