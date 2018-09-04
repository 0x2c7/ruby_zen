module RubyZen::Indexers
  class CoreRubyIndexer
    attr_reader :file_list

    def initialize(filename, engine:, logger:)
      @filename = filename
      @engine = engine
      @logger = logger
    end

  # def start
  #   gather_files
  #
  #   return [] if file_list.empty?
  #
  #   @logger.debug("#{file_list.length} files are to be indexed")
  #
  #   file_list.map do |filename|
  #     @current = filename
  #     parse_file(filename)
  #   end.compact
  #
  #   @logger.debug('Indexing completed')
  # end

    def start
      content = RubyZen::Encoding.read_file(@filename, Encoding::UTF_8)
      RubyZen::Parser::C.new(content, @engine).scan
    end

    private

    def parse_file(filename)
      filename = filename.encode(Encoding::UTF_8)

      return if RubyZen::Parser.binary? filename

      content = RubyZen::Encoding.read_file filename, Encoding::UTF_8

      return unless content

      parser = RubyZen::Parser.for top_level, filename, content, @options, @stats

      return unless parser

      parser.scan
    end

    def gather_files
      files = ['.']

      file_list = normalize_file_list(files)

      file_list = file_list.uniq

      file_list = remove_unparseable file_list

      file_list.sort
    end

    def normalize_file_list(files)
      file_list = []

      relative_files.each do |rel_file_name|
        next if rel_file_name.end_with? 'created.rid'
        next if exclude_pattern && exclude_pattern =~ rel_file_name
        stat = File.stat rel_file_name rescue next

        case type = stat.ftype
        when 'file' then
          next if last_modified = @last_modified[rel_file_name] and
                  stat.mtime.to_i <= last_modified.to_i

          if force_doc or RDoc::Parser.can_parse(rel_file_name) then
            file_list << rel_file_name.sub(/^\.\//, '')
            @last_modified[rel_file_name] = stat.mtime
          end
        when 'directory' then
          next if rel_file_name == "CVS" || rel_file_name == ".svn"

          created_rid = File.join rel_file_name, 'created.rid'
          next if File.file? created_rid

          dot_doc = File.join rel_file_name, RDoc::DOT_DOC_FILENAME

          if File.file? dot_doc then
            file_list << parse_dot_doc_file(rel_file_name, dot_doc)
          else
            file_list << list_files_in_directory(rel_file_name)
          end
        else
          warn "rdoc can't parse the #{type} #{rel_file_name}"
        end
      end

      file_list.flatten
    end
  end
end
