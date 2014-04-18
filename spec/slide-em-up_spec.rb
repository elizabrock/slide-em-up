#!/usr/bin/env ruby

require 'simplecov'
SimpleCov.start

require "minitest/autorun"
require_relative "../lib/slide-em-up"

describe SlideEmUp do
  describe "a file based presentation" do
    before do
      filename = File.expand_path("../example/presentation.md", __FILE__)
      options = { "theme" => "3d_slideshow", filename: filename }
      @presentation = SlideEmUp::Presentation.new(options)
    end

    it "has a version number" do
      SlideEmUp::VERSION.must_match /\d+\.\d+\.\d+/
    end

    it "has a slide count" do
      @presentation.slide_count.must_equal 5
    end

    describe "Building a presentation" do
      it "has a title" do
        @presentation.meta.title.must_equal "An example presentation"
      end

      it "has a theme" do
        @presentation.theme.title.must_equal "3d_slideshow"
      end

      it "has 2 sections, each one with a title" do
        @presentation.sections.length.must_equal 2
        expected = ["Section One", "Section 2"]
        @presentation.sections.map(&:title).must_equal expected
      end
    end

    describe "Finding assets" do
      it "can find an asset in the presentation" do
        @presentation.path_for_asset("octocat.png").must_equal File.expand_path("../example/octocat.png", __FILE__)
      end
      it "can find an asset in the theme" do
        @presentation.path_for_asset("/css/main.css").must_equal File.expand_path("../../themes/3d_slideshow/css/main.css", __FILE__)
      end

      it "can find an asset in common" do
        @presentation.path_for_asset("/fonts/crimson_text.ttf").must_equal File.expand_path("../../themes/common/fonts/crimson_text.ttf", __FILE__)
      end
    end

    describe "Rendering HTML" do
      before do
        @html = @presentation.html
      end

      it "has 2 sections" do
        2.times do |i|
          @html.must_match /<section id="section-#{i}">/
        end
      end

      it "has 2 slides in the first section" do
        2.times do |i|
          @html.must_match /<section id="slide-0-#{i}"/
        end
      end

      it "renders the classes on the slides" do
        @html.must_match /<section id="slide-1-1" class="foo-class bar-class">/
      end

      it "renders Markdown" do
        @html.must_match /<li>foo<\/li>\s*<li>bar<\/li>\s*<li>baz<\/li>/
      end

      it "renders code blocks" do
        @html.must_match /<code class="prettyprint linenums lang-ruby">.+<\/code>/m
      end
    end
  end
  describe "a content based presentation" do
    before do
      contents = File.read(File.expand_path("../example/presentation.md", __FILE__))
      options = { "theme" => "3d_slideshow", contents: contents}
      @presentation = SlideEmUp::Presentation.new(options)
    end

    it "has a version number" do
      SlideEmUp::VERSION.must_match /\d+\.\d+\.\d+/
    end

    it "has a slide count" do
      @presentation.slide_count.must_equal 5
    end

    describe "Building a presentation" do
      it "has a title" do
        @presentation.meta.title.must_equal "An example presentation"
      end

      it "has a theme" do
        @presentation.theme.title.must_equal "3d_slideshow"
      end

      it "has 2 sections, each one with a title" do
        @presentation.sections.length.must_equal 2
        expected = ["Section One", "Section 2"]
        @presentation.sections.map(&:title).must_equal expected
      end
    end

    describe "Finding assets" do
      it "can't find an asset in the presentation" do
        assert_nil @presentation.path_for_asset("octocat.png")
      end
      it "can find an asset in the theme" do
        @presentation.path_for_asset("/css/main.css").must_equal File.expand_path("../../themes/3d_slideshow/css/main.css", __FILE__)
      end

      it "can find an asset in common" do
        @presentation.path_for_asset("/fonts/crimson_text.ttf").must_equal File.expand_path("../../themes/common/fonts/crimson_text.ttf", __FILE__)
      end
    end

    describe "Rendering HTML" do
      before do
        @html = @presentation.html
      end

      it "has 2 sections" do
        2.times do |i|
          @html.must_match /<section id="section-#{i}">/
        end
      end

      it "has 2 slides in the first section" do
        2.times do |i|
          @html.must_match /<section id="slide-0-#{i}"/
        end
      end

      it "renders the classes on the slides" do
        @html.must_match /<section id="slide-1-1" class="foo-class bar-class">/
      end

      it "renders Markdown" do
        @html.must_match /<li>foo<\/li>\s*<li>bar<\/li>\s*<li>baz<\/li>/
      end

      it "renders code blocks" do
        @html.must_match /<code class="prettyprint linenums lang-ruby">.+<\/code>/m
      end
    end
  end
end
