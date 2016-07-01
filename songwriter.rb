require_relative 'shoes_setup'
require_relative 'song'
require_relative 'string_extensions'
require_relative 'shoes_extensions'

APP_NAME = 'Musical Sniffle'.freeze

class Songwriter < Shoes
  url '/', :intro_window
  url '/(\w+)', :song_window

  def song_window(song_name)
    @current_song = Song.new(song_name)

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
      stack do
        p @current_song.lyrics
        list_box items: @current_song.lyrics, align: 'center'
        edit_box width: 0.9, height: 0.8
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

Shoes.app(width: 600, height: 600, margin: 10, title: APP_NAME)
