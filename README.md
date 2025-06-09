```sh
ruby chrome_no_animation_until_screenshot_spec.rb
```

See test file comments.

Failure output: see opacity:0 on the parent element before the screenshot, and opacity:1 after the screenshot.

Interestingly, omething is building up, something is leaking, because the mouse movements get slower and slower to perform 😮🤔
```
$ ruby chrome_no_animation_until_screenshot_spec.rb

Randomized with seed 10349

Chrome blocks animations from running until a screenshot is saved
Driver options: {args: ["--headless=new", "--disable-site-isolation-trials", "--no-sandbox", "--disable-dev-shm-usage"], prefs: {}, emulation: {}, local_state: {}, exclude_switches: [], perf_logging_prefs: {}, window_types: [], browser_name: "chrome"}

MOUSE MOVEMENT: move to "More information" link
MOUSE MOVEMENT: move to 100,20
MOUSE MOVEMENT: adjust 10,20
MOUSE MOVEMENT: DONE
  is expected to download file "example-org.html"

MOUSE MOVEMENT: move to "More information" link
MOUSE MOVEMENT: move to 100,20
MOUSE MOVEMENT: adjust 10,20
MOUSE MOVEMENT: DONE
  is expected to download file "example-org.html"

MOUSE MOVEMENT: move to "More information" link
MOUSE MOVEMENT: move to 100,20
MOUSE MOVEMENT: adjust 10,20
MOUSE MOVEMENT: DONE
  is expected to download file "example-org.html"

MOUSE MOVEMENT: move to "More information" link
MOUSE MOVEMENT: move to 100,20
MOUSE MOVEMENT: adjust 10,20
MOUSE MOVEMENT: DONE
BROWSER: 137.0.7151.69
  "137.0.7151.68 (2989ffee9373ea8b8623bd98b3cb350a8e95cadc-refs/branch-heads/7151@{#1873})"

FAILURE: capturing the style before screenshot advances it
link visible to Capybara finders? false
computed style:
{"el" =>
  {"display" => "inline",
   "html" => "<a href=\"\" download=\"example-org.html\">Download me</a>",
   "opacity" => "1",
   "visibility" => "visible"},
 "parent" =>
  {"display" => "block",
   "html" =>
    "<p class=\"fade-in\"><a href=\"\" download=\"example-org.html\">Download me</a></p>",
   "opacity" => "0",
   "visibility" => "visible"}}
checkVisibility: base                  true
checkVisibility: contentVisibilityAuto true
checkVisibility: opacityProperty       false
checkVisibility: visibilityProperty    true

MOUSE MOVEMENT: move to "More information" link
MOUSE MOVEMENT: move to 100,20
MOUSE MOVEMENT: adjust 10,20
MOUSE MOVEMENT: DONE

RETRY: checking visibility again after screenshot
link visible to Capybara finders? false
computed style:
{"el" =>
  {"display" => "inline",
   "html" => "<a href=\"\" download=\"example-org.html\">Download me</a>",
   "opacity" => "1",
   "visibility" => "visible"},
 "parent" =>
  {"display" => "block",
   "html" =>
    "<p class=\"fade-in\"><a href=\"\" download=\"example-org.html\">Download me</a></p>",
   "opacity" => "0",
   "visibility" => "visible"}}
checkVisibility: base                  true
checkVisibility: contentVisibilityAuto true
checkVisibility: opacityProperty       false
checkVisibility: visibilityProperty    true

SCREENSHOT: taking a screenshot to allow the animation to progress and complete

RETRY: checking visibility again after screenshot
link visible to Capybara finders? true
computed style:
{"el" =>
  {"display" => "inline",
   "html" => "<a href=\"\" download=\"example-org.html\">Download me</a>",
   "opacity" => "1",
   "visibility" => "visible"},
 "parent" =>
  {"display" => "block",
   "html" =>
    "<p class=\"fade-in\"><a href=\"\" download=\"example-org.html\">Download me</a></p>",
   "opacity" => "1",
   "visibility" => "visible"}}
checkVisibility: base                  true
checkVisibility: contentVisibilityAuto true
checkVisibility: opacityProperty       true
checkVisibility: visibilityProperty    true
  is expected to download file "example-org.html" (FAILED - 1)

Failures:

  1) Chrome blocks animations from running until a screenshot is saved is expected to download file "example-org.html"
     Failure/Error: expect { click_on 'Download me' }.to download_file('example-org.html')
     
     Capybara::ElementNotFound:
       Unable to find visible link or button "Download me"
```

Works fine in an alpine container, which means either Chromium doesn't have the bug (and I don't know how to install a stable Chromium on macOS that isn't quarantined by macOS) or it truly is just my mac system that's borfed.
```sh
docker build -t chrome-downloads-block-css-animations . && \
docker run --rm -it chrome-downloads-block-css-animations
```
