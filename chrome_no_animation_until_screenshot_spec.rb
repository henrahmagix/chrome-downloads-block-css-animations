# BUG: after downloading a certain number of files in the Chrome Headless browser, it stops progressing CSS animations.
# Replicable on 137.0.7151.68 (chromedriver 2989ffee9373ea8b8623bd98b3cb350a8e95cadc-refs/branch-heads/7151@{#1873})
#
# This test file repeats the same test until failure: it inserts a fading-in link into the page that downloads the
# current page and then clicks it. If the link is invisible, it prints some visibility information and then takes a
# screenshot, which causes the CSS fade-in animation to complete, proven by printing the visibility info again. You
# should see firstly `"opacity" => "0"` on the `.fade-in` element, and see that change to `"1"` after the screenshot.
# The animation itself is extremely short, so it's definitely being blocked from progressing immediately upon creation.

require 'bundler/inline'

gemfile do
  source 'https://rubygems.org'
  gem 'rspec', '~> 3.13'
  gem 'capybara', '~> 3.40'
  gem 'selenium-webdriver', '~> 4.33'
  gem 'pry', '~> 0.15.2'
end

# require 'pry'
require 'rspec/autorun'
require_relative './spec_helper'
require 'capybara/rspec'
require 'selenium/webdriver'

DOWNLOADS_DIR = File.expand_path('downloads', __dir__)

Capybara.save_path = File.expand_path('screenshots', __dir__)

DRIVER = :selenium_chrome_headless
# DRIVER = :selenium_chrome # bug never occurs in a head-full browser

RSpec.configure do |c|
  c.fail_fast = true
  c.formatter = "doc"
  c.before { page.driver.browser.download_path = DOWNLOADS_DIR }
end

RSpec.describe 'Chrome blocks animations from running until a screenshot is saved', type: :feature, driver: DRIVER do
  100.times { it { run } }

  def run
    visit 'https://example.org' # use example.org so we don't have to run a webserver

    # Add some fading-in content to the page.
    add_html_to_page <<~HTML, append_to: 'body > div'
      <style>
      @keyframes fade { from { opacity: 0; } }
      .fade-in { animation: fade 1ms both; }
      </style>
      <p class="fade-in"><a href="" download="example-org.html">Download me</a></p>
    HTML

    # If the repeated tests are passing for you, try uncommenting this sleep here.
    # sleep 1

    begin
      # Just confirming the file download is working correctly in the browser, without which this bug doesn't occur.
      before_url = current_url
      expect { click_on 'Download me' }.to download_file('example-org.html')
    rescue Capybara::ElementNotFound, RSpec::Expectations::ExpectationNotMetError
      if (now_url = current_url) != before_url
        puts "URL has changed from #{before_url} to #{now_url}, but shouldn't because the browser should download instead of visiting"
      end

      caps = page.driver.browser.capabilities
      puts "BROWSER: #{caps[:browser_version]}\n  #{caps['chrome']&.fetch('chromedriverVersion').inspect}"


      puts
      puts 'FAILURE: capturing the style before screenshot advances it'
      check_element_visibility = proc do
        puts "link visible to Capybara finders? #{find_link('Download me', visible: :all).visible?}"
        computed_style = execute_script <<~JS
          var el = document.querySelector("[download]");
          var style = getComputedStyle(el);
          var parent_style = getComputedStyle(el.parentElement);
          return {
            el:     {html:el.outerHTML,               display:style.display,        opacity:style.opacity,        visibility:style.visibility},
            parent: {html:el.parentElement.outerHTML, display:parent_style.display, opacity:parent_style.opacity, visibility:parent_style.visibility}
          }
        JS
        puts "computed style:"
        pp computed_style
        puts "checkVisibility: base                  #{execute_script %(return document.querySelector("[download]").checkVisibility())}"
        puts "checkVisibility: contentVisibilityAuto #{execute_script %(return document.querySelector("[download]").checkVisibility({contentVisibilityAuto:true}))}"
        puts "checkVisibility: opacityProperty       #{execute_script %(return document.querySelector("[download]").checkVisibility({opacityProperty:true}))}"
        puts "checkVisibility: visibilityProperty    #{execute_script %(return document.querySelector("[download]").checkVisibility({visibilityProperty:true}))}"
      end
      check_element_visibility.call

      puts
      puts 'SCREENSHOT: taking a screenshot to allow the animation to progress and complete'
      save_screenshot 'visibility.png'

      puts
      puts 'RETRY: checking visibility again after screenshot'
      check_element_visibility.call

      raise
    end
  end

  private

    def add_html_to_page(html, append_to:)
      execute_script <<~JS, html, append_to
        var template = document.createElement('template');
        template.innerHTML = arguments[0];
        document.querySelector(arguments[1]).append(template.content);
      JS
    end

    matcher :download_file do |expected|
      supports_block_expectations

      def get_download_files_with_modified_time
        Dir.glob(File.join(DOWNLOADS_DIR, '*')).select(&File.method(:file?)).to_h { |file| [file, File.mtime(file)] }
      rescue Errno::ENOENT
        []
      end

      match do |block|
        raise ArgumentError, 'must be given block' unless block === Proc

        @files_before = get_download_files_with_modified_time
        block.call

        timer = Capybara::Helpers.timer(expire_in: 3)
        loop do
          # Ignore same-named files that have not been modified since before the block call.
          @new_files = get_download_files_with_modified_time.select { |file, mtime| !@files_before.key?(file) || @files_before[file] < mtime }

          break true if @new_files.any? { |filename, _| values_match?(expected, File.basename(filename)) }

          break false if timer.expired?

          sleep 0.1
        end
      end

      failure_message do
        msg = "expected block to download file #{description_of(expected)}"
        if @new_files.empty?
          "#{msg}, but none new were downloaded."
        else
          "#{msg}, but it was not found in #{@new_files.keys}"
        end
      end
    end
end
