module RubyCue
  class Cuesheet
    attr_reader :cuesheet, :songs, :track_duration, :performer, :title, :file, :genre

    def initialize(cuesheet, track_duration=nil)
      @cuesheet = cuesheet      
      @reg = {
        :track => %r(TRACK (\d{1,3}) AUDIO),
       :performer => %r(PERFORMER "(.*)"),
        :title => %r(TITLE "(.*)"),
        :index => %r(INDEX \d{1,3} (\d{1,4}):(\d{1,2}):(\d{1,2})),
        :file => %r(FILE "(.*)"),
        :genre => %r(REM GENRE (.*)\b)
      }
      @track_duration = RubyCue::Index.new(track_duration) if track_duration
    end

    def parse!
      @songs = parse_titles.map{|title| {:title => title}}
      @songs.each_with_index do |song, i|
  #      song[:performer] = parse_performers[i]
        song[:track] = parse_tracks[i]
        song[:index] = parse_indices[i]
        song[:file] = parse_files[i]
      end
      parse_genre
   #   raise RubyCue::InvalidCuesheet.new("Field amounts are not all present. Cuesheet is malformed!") unless valid?
      calculate_song_durations!
      true
    end

    def position(value)
      index = Index.new(value)
      return @songs.first if index < @songs.first[:index]
      @songs.each_with_index do |song, i|
        return song if song == @songs.last
        return song if between(song[:index], @songs[i+1][:index], index)
      end
    end

    #def valid?
     # @songs.all? do |song|
  #      valid_perfomer = (@performer if @file) || song[:performer]
   #     valid_perfomer && [:track, :index, :title].all? do |key|
     #     song[key] != nil
    #    end
     # end
    #end

  private

    def calculate_song_durations!
      @songs.each_with_index do |song, i|
        if song == @songs.last
          song[:duration] = (@track_duration - song[:index]) if @track_duration
          return
        end
        song[:duration] = @songs[i+1][:index] - song[:index]
      end
    end

    def between(a, b, position_index)
      (position_index > a) && (position_index < b)
    end

    def parse_titles
      unless @titles
        @titles = cuesheet_scan(:title).map{|title| title.first}
        @title = @titles.delete_at(0)
      end
      @titles
    end

   # def parse_performers
    #  unless @performers
     #   @performers = cuesheet_scan(:performer).map{|performer| performer.first}
      #  @performer = @performers.delete_at(0)
      #end
      #@performers
    #end

    def parse_tracks
      @tracks ||= cuesheet_scan(:track).map{|track| track.first.to_i}
    end

    def parse_indices
      @indices ||= cuesheet_scan(:index).map{|index| RubyCue::Index.new([index[0].to_i, index[1].to_i, index[2].to_i])}
    end

    def parse_files
      unless @files
        @files = cuesheet_scan(:file).map{|file| file.first}
        @file = @files.delete_at(0) if @files.size == 1
      end
      @files
    end

    def parse_genre
      @cuesheet.scan(@reg[:genre]) do |genre|
        @genre = genre.first
        break
      end
    end

    def cuesheet_scan(field)
      scan = @cuesheet.scan(@reg[field])
      raise InvalidCuesheet.new("No fields were found for #{field.to_s}") if scan.empty?
      scan
    end

  end
end