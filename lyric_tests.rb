require_relative 'lyric'
require_relative 'utilities'
require 'test/unit'
require 'fakefs'
require 'fileutils'

class TestLyric < Test::Unit::TestCase
  include Utilities
  TEST_FILENAME = 'lyric1'.freeze
  TEST_DATETIME = '2016-01-01,11:35'.freeze
  TEST_LABELS = 'draft'.freeze
  TEST_LYRICS = 'Lyrics'.freeze

  def setup
    Dir.chdir('/')
    Dir.mkdir('lyrics')
  end

  def teardown
    Dir.chdir('/')
    FileUtils.rm_rf('lyrics')
  end

  def test_opening_lyrics
    FakeFS do
      lyrics_file = File.new("lyrics/#{TEST_FILENAME}", 'w+', 0755)
      lyrics_file.puts("date: #{TEST_DATETIME}", "labels: #{TEST_LABELS}")
      lyrics_file.write(TEST_LYRICS)
      lyrics_file.rewind
      lyric = Lyric.new(TEST_FILENAME)
      assert_equal lyric.text, TEST_LYRICS
      assert_equal lyric.labels, [TEST_LABELS]
      assert_equal lyric.date.strftime('%Y-%m-%d,%H:%M'), TEST_DATETIME

      assert File.file?("lyrics/#{TEST_FILENAME}.bak")
      backup = File.open("lyrics/#{TEST_FILENAME}.bak", 'r')
      assert backup.read == lyrics_file.read

      lyrics_file.close
      backup.close
    end
  end

  def test_opening_empty_lyrics
    FakeFS do
      lyrics_file = File.new("lyrics/#{TEST_FILENAME}", 'w+', 0755)
      lyric = Lyric.new(TEST_FILENAME)
      assert_equal '', lyric.text
      assert_equal [], lyric.labels
      assert lyric.date.strftime('%Y-%m-%d,%H:%M').match(/\d\d\d\d-\d\d-\d\d,\d\d:\d\d/)

      assert File.file?("lyrics/#{TEST_FILENAME}.bak")
      backup = File.open("lyrics/#{TEST_FILENAME}.bak", 'r')
      assert backup.read == lyrics_file.read

      lyrics_file.close
      backup.close
    end
  end

  def test_creating_new_lyrics
    FakeFS do
      assert !File.file?("lyrics/#{TEST_FILENAME}")
      lyric = Lyric.new(TEST_FILENAME)
      assert File.file?("lyrics/#{TEST_FILENAME}")
      lyrics_file = File.open("lyrics/#{TEST_FILENAME}", 'r')

      assert_equal lyric.text, ''
      assert_equal lyric.labels, []
      assert lyric.date.strftime("%Y-%m-%d,%H:%M").match(/\d\d\d\d-\d\d-\d\d,\d\d:\d\d/)
      assert File.file?("lyrics/#{TEST_FILENAME}.bak")
      backup = File.open("lyrics/#{TEST_FILENAME}.bak", 'r')
      assert backup.read == lyrics_file.read

      lyrics_file.close
      backup.close
    end
  end

  def test_saving_lyrics
    FakeFS do
      lyric = Lyric.new(TEST_FILENAME)
      assert_equal lyric.text, ''
      assert_equal lyric.labels, []
      assert lyric.date.strftime("%Y-%m-%d,%H:%M").match(/\d\d\d\d-\d\d-\d\d,\d\d:\d\d/)
      lyric.text = 'text'
      lyric.labels << 'important'
      lyric.date = Time.new(2001, 9, 11)
      lyric.save
      assert File.file?(File.join('lyrics', TEST_FILENAME))
      existing_lyric = Lyric.new(TEST_FILENAME)
      assert_equal existing_lyric.text, 'text'
      assert_equal existing_lyric.labels, ['important']
      assert_equal existing_lyric.date, Time.new(2001, 9, 11)
    end
  end

  def test_deleting_lyrics
    FakeFS do
      lyric = Lyric.new(TEST_FILENAME)
      assert File.file?("lyrics/#{TEST_FILENAME}")
      lyric.delete
      assert !File.file?("lyrics/#{TEST_FILENAME}")
    end
  end
end
