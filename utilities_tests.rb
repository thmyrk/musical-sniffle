require_relative 'utilities'
require 'test/unit'
require 'fakefs'
require 'fileutils'

class TestUtilities < Test::Unit::TestCase
  include Utilities

  TEST_FILENAME = 'lyric1'

  def teardown
    Dir.chdir('/')
    FileUtils.rm_rf('songs')
  end

  def test_cleaningup_backup_files
    FakeFS do
      Dir.chdir('/')
      FileUtils.mkdir_p('songs/song11/lyrics')
      FileUtils.mkdir_p('songs/song11/ideas')
      FileUtils.mkdir_p('songs/song11/recordings')
      FileUtils.mkdir_p('songs/song22/lyrics')
      FileUtils.mkdir_p('songs/song22/ideas')
      FileUtils.mkdir_p('songs/song22/recordings')
      Dir.chdir('songs') do
        Dir.entries('.').reject { |entry| entry == '.' || entry == '..' }.each do |song|
          %w(lyrics ideas).each do |section|
            File.new("#{song}/#{section}/#{section}1", 'w+')
            File.new("#{song}/#{section}/#{section}1.bak", 'w+')
            File.new("#{song}/#{section}/#{section}2.bak", 'w+')
          end
        end
      end
      cleanup_useless_backup_files
      Dir.chdir('songs') do
        Dir.entries('.').reject { |entry| entry == '.' || entry == '..' }.each do |song|
          %w(lyrics ideas).each do |section|
            assert File.file?("#{song}/#{section}/#{section}1")
            assert File.file?("#{song}/#{section}/#{section}1.bak")
            assert !File.file?("#{song}/#{section}/#{section}2.bak")
          end
        end
      end
    end
  end

  def test_append_time
    assert append_time(TEST_FILENAME).match(/\d{10}/)
  end

  def test_successully_cut_time
    result = cut_time("1234567890#{TEST_FILENAME}")
    assert_equal result[0], '1234567890'
    assert_equal result[1], TEST_FILENAME
  end

  def test_cut_no_time
    result = cut_time(TEST_FILENAME)
    assert_equal result[0], nil
    assert_equal result[1], TEST_FILENAME
  end

  def test_successful_replace_time
    file = cut_time("1234567890#{TEST_FILENAME}")
    new_filename = replace_time(file[1])
    assert new_filename.match(/\d{10}/)
    assert_not_equal new_filename, file[0]
  end

  def test_replace_time_when_no_time
    file = cut_time(TEST_FILENAME)
    new_filename = replace_time(file[1])
    assert new_filename.match(/\d{10}/)
    assert_not_equal new_filename, file[0]
  end
end
