require_relative 'song'
require_relative 'string_extensions_tests'
require 'test/unit'
require 'fakefs'

APP_ROOT = Dir.pwd

class TestSong < Test::Unit::TestCase
  SONG_NAME = 'song111'.freeze

  FakeFS do
    Dir.mkdir('songs')
  end

  def test_create_new_song
    FakeFS do
      assert !File.directory?("/songs/#{SONG_NAME}")
      new_song = Song.new(SONG_NAME)
      assert File.directory?("/songs")
      assert File.directory?("/songs/#{SONG_NAME}")
      assert File.directory?("/songs/#{SONG_NAME}/lyrics")
      assert File.directory?("/songs/#{SONG_NAME}/ideas")
      assert File.directory?("/songs/#{SONG_NAME}/recordings")
      assert_equal new_song.lyrics, []
      assert_equal new_song.ideas, []
      assert_equal new_song.recordings, []
    end
  end

  def test_open_existing_song
    FakeFS do
      Song.new(SONG_NAME)
      assert File.directory?('/songs')
      assert File.directory?("/songs/#{SONG_NAME}")
      Dir.chdir("/songs/#{SONG_NAME}") do
        assert File.directory?('lyrics')
        assert File.directory?('ideas')
        assert File.directory?('recordings')
        File.new('lyrics/lyric1', 'w+', 0755)
        File.new('lyrics/lyric2', 'w+', 0755)
        File.new('ideas/idea1', 'w+', 0755)
        File.new('ideas/idea2', 'w+', 0755)
        File.new('recordings/rec1.wav', 'w+', 0755)
        File.new('recordings/rec2.wav', 'w+', 0755)
        existing_song = Song.new(SONG_NAME)
        assert_equal existing_song.lyrics, ['lyric1', 'lyric2']
        assert_equal existing_song.ideas, ['idea1', 'idea2']
        assert_equal existing_song.recordings, ['rec1.wav', 'rec2.wav']
      end
    end
  end

  def test_enter_song_directory
    FakeFS do
      song = Song.new(SONG_NAME)
      song.enter_song_directory
      assert_equal Dir.pwd, "/songs/#{song.name.to_filename}"
    end
  end
end
