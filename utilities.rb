module Utilities
  def cleanup_useless_backup_files
    Dir.mkdir('songs') unless File.directory? 'songs'
    song_list = Dir.entries('songs').select do |entry|
      File.directory?("songs/#{entry}") && entry != '.' && entry != '..'
    end
    song_list.each do |song|
      Dir.chdir(File.join 'songs', song) do
        %w(lyrics ideas recordings).each do |section|
          Dir.chdir section do
            Dir.entries('.').reject { |entry| entry == '.' || entry == '..'}.each do |entry|
              if File.extname(entry) == '.bak' && !File.file?(entry.gsub '.bak', '')
                File.delete entry
              end
            end
          end
        end
      end
    end
  end

  def append_time(filename)
    "#{Time.now.to_i}#{filename}"
  end

  def cut_time(filename)
   (time = filename.slice(/\d{10}/, 0)) ? [time, filename.gsub(time, '')] : [time, filename]
  end

  def replace_time(filename)
    file = cut_time(filename)
    append_time file[1]
  end
end
