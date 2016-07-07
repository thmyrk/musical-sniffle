require_relative 'lyric'
require 'test/unit'
require 'fakefs'

TEST_FILENAME = "lyric1".freeze
TEST_DATETIME = "2016-01-01,11:35"
TEST_LABELS = "draft"
TEST_LYRICS = "Lyrics"

class TestLyric < Test::Unit::TestCase

  FakeFS do
    Dir.mkdir("lyrics")
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
      assert_equal lyric.date.strftime("%Y-%m-%d,%H:%M"), TEST_DATETIME

      assert File.file?("lyrics/#{TEST_FILENAME}.bak")
      backup = File.open("lyrics/#{TEST_FILENAME}.bak", 'r')
      assert backup.read == lyrics_file.read

      lyrics_file.close
      backup.close
    end
  end
end
