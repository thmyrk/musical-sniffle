require_relative 'shoes_setup'
require_relative 'song'
require_relative 'lyric'
require_relative 'string_extensions'
require_relative 'shoes_extensions'
require_relative 'utilities'

APP_NAME = 'Musical Sniffle'.freeze
APP_ROOT = Dir.pwd
WINDOW_WIDTH = 600
WINDOW_HEIGHT = 600

class MusicalSniffle < Shoes
  include Utilities
  url '/', :intro_window
  url '/(\w+)', :song_window

  def song_window(song_name)
    @current_song = Song.new(song_name)
    @current_song.enter_song_directory

    flow do
      @lyrics_tab = stack(width: 0.33) do
        para 'Lyrics', align: 'center'
      end
      @ideas_tab = stack(width: 0.33) do
        para 'Ideas', align: 'center'
      end
      @recordings_tab = stack(width: 0.33) do
        para 'Recordings', align: 'center'
      end
    end

    @lyrics_flow = flow do
      stack width: 0.5, margin_top: 30, margin_bottom: 20 do
        # new lyrics name line
        @new_song_line = edit_line 'New lyric name', width: 1.0, margin_left: 30, margin_right: 30
      end
      stack width: 0.5, margin_top: 30, margin_bottom: 20 do
        # new lyrics button
        button 'Create new lyrics', width: 1.0, margin_left: 30, margin_right: 30 do
          new_lyric = Lyric.new @new_song_line.text.to_filename
          @current_song.add_section_element 'lyrics', new_lyric.filename
          @current_lyric = new_lyric
          @lyrics_list.items = @current_song.lyrics.map(&:to_songname)
          @lyrics_list.choose new_lyric.filename
        end
      end
      stack width: 1.0, margin_left: 20, margin_right: 20 do
        # list of song's lyrics
        @lyrics_list = list_box items: @current_song.lyrics.map(&:to_songname), align: 'center' do |list|
          @current_lyric = Lyric.new list.text.to_filename
          @lyrics_box.text = @current_lyric.text
        end
        @lyrics_box = edit_box width: 1.0, height: 300
      end
      stack width: 0.5, margin_top: 30, margin_bottom: 20 do
        # save button
        button 'Save', width: 1.0, margin_left: 30, margin_right: 100 do
          @current_lyric.text = @lyrics_box.text
          @current_lyric.date = Time.now
          @current_lyric.save
          puts 'Save successful'
        end
      end
      stack width: 0.5, margin_top: 30, margin_bottom: 20 do
        # delete button
        button 'Delete', width: 1.0, margin_left: 100, margin_right: 30 do
          @current_song.remove_section_element 'lyrics', @current_lyric.filename
          @lyrics_list.items = @current_song.lyrics.map(&:to_songname)
          @current_lyric.delete
          p "Delete successful"
        end
      end
    end

    @ideas_flow = flow do
      stack do
        list_box items: @current_song.ideas
      end
    end

    @recordings_flow = flow do
      stack do
        list_box items: @current_song.recordings
      end
    end

    @active_tab = @lyrics_tab
    @active_section = @lyrics_flow

    redraw_tabs
    show_active_section
    register_events
  end

  def intro_window
    cleanup_useless_backup_files
    available_songs = read_available_songs
    stack do
      para 'Select your song'
      @available_songs_list = list_box(items: available_songs) do |list|
        visit "/#{list.text}"
      end
      para 'Create new song'
      @new_song_edit_line = edit_line('Song name')
      button 'Add song' do
        visit "/#{@new_song_edit_line.text}"
      end
    end
  end

  private

  def read_available_songs
    song_list = []
    Dir.mkdir('songs') unless File.directory?('songs')
    Dir.entries('songs').reject { |entry| entry.match(/\W/) }.each do |entry|
      song_list << entry.to_songname if File.directory?("songs/#{entry}")
    end
    song_list
  end

  def register_events
    @lyrics_tab.click do
      @active_tab = @lyrics_tab
      @active_section = @lyrics_flow

      redraw_tabs
      show_active_section
    end

    @ideas_tab.click do
      @active_tab = @ideas_tab
      @active_section = @ideas_flow

      redraw_tabs
      show_active_section
    end

    @recordings_tab.click do
      @active_tab = @recordings_tab
      @active_section = @recordings_flow

      redraw_tabs
      show_active_section
    end
  end

  def redraw_tabs
    section_tabs = [@lyrics_tab, @ideas_tab, @recordings_tab]

    active_tab_border = @active_tab.get_first_element_of_class(Shoes::Border)
    active_tab_border.remove if active_tab_border

    active_tab_background = @active_tab.get_first_element_of_class(Shoes::Background)
    active_tab_background.remove if active_tab_background
    @active_tab.prepend { background(whitesmoke) }

    (section_tabs - [@active_tab]).each do |tab|
      tab_border = tab.get_first_element_of_class(Shoes::Border)
      tab.prepend { border silver, strokewidth: 1 } unless tab_border

      tab_background = tab.get_first_element_of_class(Shoes::Background)
      tab_background.remove if tab_background
      tab.prepend { background(gainsboro) }
    end
  end

  def show_active_section
    section_flows = [@lyrics_flow, @ideas_flow, @recordings_flow]

    @active_section.show
    (section_flows - [@active_section]).each(&:hide)
  end
end

MusicalSniffle.app(width: WINDOW_WIDTH, height: WINDOW_HEIGHT, margin: 10, title: APP_NAME)
