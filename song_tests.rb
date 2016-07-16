require_relative 'song'
require_relative 'lyric'
require_relative 'string_extensions'
require_relative 'utilities'
require 'test/unit'
require 'fileutils'
require 'fakefs'

APP_ROOT = Dir.pwd

class TestSong < Test::Unit::TestCase
  include Utilities
  SONG_NAME = 'song111'.freeze
  LYRIC_NAME = 'lyric1'.freeze
  IDEA_NAME = 'idea1'.freeze
  RECORDING_NAME = 'recording1.wav'.freeze

  def setup
    FakeFS do
      Dir.chdir('/')
      Dir.mkdir('songs')
    end
  end

  def teardown
    FakeFS do
      Dir.chdir('/')
      FileUtils.rm_rf('songs')
    end
  end

  def test_create_new_song
    FakeFS do
      assert File.directory?("songs")
      assert !File.directory?("songs/#{SONG_NAME}")
      new_song = Song.new(SONG_NAME)
      assert File.directory?("songs/#{SONG_NAME}")
      assert File.directory?("songs/#{SONG_NAME}/lyrics")
      assert File.directory?("songs/#{SONG_NAME}/ideas")
      assert File.directory?("songs/#{SONG_NAME}/recordings")
      assert_equal new_song.lyrics, []
      assert_equal new_song.ideas, []
      assert_equal new_song.recordings, []
    end
  end

  def test_open_existing_song
    FakeFS do
      assert File.directory?('songs')
      song = Song.new(SONG_NAME)
      assert File.directory?("songs/#{SONG_NAME}")
      Dir.chdir("songs/#{SONG_NAME}") do
        assert File.directory?('lyrics')
        assert File.directory?('ideas')
        assert File.directory?('recordings')
        File.new("lyrics/#{LYRIC_NAME}", 'w+', 0755)
        File.new("ideas/#{IDEA_NAME}", 'w+', 0755)
        File.new("recordings/#{RECORDING_NAME}", 'w+', 0755)
        song.add_section_element 'lyrics', LYRIC_NAME
        song.add_section_element 'ideas', IDEA_NAME
        song.add_section_element 'recordings', RECORDING_NAME

        assert_equal song.lyrics, [LYRIC_NAME]
        assert_equal song.ideas, [IDEA_NAME]
        assert_equal song.recordings, [RECORDING_NAME]
      end
      existing_song = Song.new(SONG_NAME)
      assert_equal existing_song.lyrics, [LYRIC_NAME]
      assert_equal existing_song.ideas, [IDEA_NAME]
      assert_equal existing_song.recordings, [RECORDING_NAME]
    end
  end

  def test_enter_song_directory
    FakeFS do
      song = Song.new(SONG_NAME)
      assert File.directory?('songs')
      assert File.directory?("songs/#{SONG_NAME}")
      song.enter_song_directory
      assert_equal Dir.pwd, "/songs/#{song.name.to_filename}"
    end
  end

  def test_deleting_lyrics
    FakeFS do
      song = Song.new(SONG_NAME)
      Dir.chdir("songs/#{SONG_NAME}") do
        Lyric.new LYRIC_NAME
        assert File.file?("lyrics/#{LYRIC_NAME}")
        song.add_section_element 'lyrics', LYRIC_NAME
        assert song.lyrics.include? LYRIC_NAME
        song.remove_section_element 'lyrics', LYRIC_NAME
        assert !song.lyrics.include?(LYRIC_NAME)
        # this deletes only lyrics from the song, not the file
        assert File.file?("lyrics/#{LYRIC_NAME}")
      end
    end
  end
end
