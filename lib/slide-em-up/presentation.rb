require "erubis"
require "yajl"

module SlideEmUp
  class Presentation
    Meta    = Struct.new(:title, :dir, :css, :js, :file, :file_contents, :author, :duration)
    Theme   = Struct.new(:title, :dir, :css, :js)
    Section = Struct.new(:number, :title, :slides)

    class Slide < Struct.new(:number, :classes, :html)
      def extract_title
        return @title if @title
        html.sub!(/<h(\d)>(.*)<\/h\1>/) { @title = $2; "" }
        @title
      end
    end

    attr_accessor :meta, :theme, :common, :sections

    def initialize(file, opts = {})
      options   = { "theme" => "rmcgibbo_slidedeck", "duration" => 60, "author" => extract_author }.merge(opts)
      @meta   = build_meta(file, options["author"], options["duration"])
      @theme  = build_theme(options["theme"])
      @common = build_theme("common")
      presentation_body = @meta.file_contents.partition(/^#\s*(.*)$/)[2]
      @sections = extract_sections_from(presentation_body, 0)[1]
    end

    def html
      str = File.read("#{theme.dir}/index.erb")
      Erubis::Eruby.new(str).result(:meta => meta, :theme => theme, :sections => sections)
    end

    def path_for_asset(asset)
      Dir[   "#{meta.dir}#{asset}"].first ||
      Dir[  "#{theme.dir}#{asset}"].first ||
      Dir[ "#{common.dir}#{asset}"].first ||
      Dir["#{meta.dir}/**#{asset}"].first
    end

    def slide_count
      sections.inject(0){ |memo, section| memo + section.slides.count }
    end

  protected

    def extract_author
      "Unknown"
    end

    def build_meta(file, author, duration)
      Meta.new.tap do |m|
        m.file = file
        m.dir = File.dirname(File.realpath(file))
        m.file_contents = File.read(m.file)
        m.title = extract_title(m.file_contents)
        m.css = []
        m.js = []
        m.author = author
        m.duration = duration
      end
    end

    def extract_title contents
      match = contents.scan(/^#\s*(.*)$/)
      match[0][0]
    end

    def build_theme(title)
      Theme.new.tap do |t|
        dir = File.expand_path("~/.slide-em-up/#{title}")
        if File.exists?(dir)
          t.dir = dir
        else
          t.dir = File.expand_path("../../../themes/#{title}", __FILE__)
        end
        t.title = title
        Dir.chdir(t.dir) do
          t.css = Dir["**/*.css"]
          t.js  = Dir["**/*.js"]
        end
      end
    end

    def extract_sections_from text, index
      head, match, tail = text.partition(/^##.*$/)
      text_before_section = head.strip
      remainder = tail.strip
      return text_before_section, [] if remainder.empty?

      match = match.scan(/##\s*(.*)/)
      section_title = match[0][0]

      slides_body, following_sections = extract_sections_from(remainder, index+1)
      slides = slides_body.empty? ? [] : extract_slides_from(slides_body)
      return text_before_section, [Section.new(index, section_title, slides), following_sections].flatten
    end

    def extract_slides_from text
      slide_bodies = text.split(/^~~~/)
      slide_bodies.map.with_index do |slide, j|
        classes, md = slide.split("\n", 2)
        html = Markdown.render(md)
        Slide.new(j, classes, html)
      end
    end
  end
end
