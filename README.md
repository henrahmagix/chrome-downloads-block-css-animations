```sh
ruby spec/chrome_no_animation_until_screenshot_spec.rb
```

See test file comments.

Failure output: see opacity:0 on the parent element before the screenshot, and opacity:1 after the screenshot.
```
$ ruby ./spec/chrome_no_animation_until_screenshot_spec.rb

Randomized with seed 63495

Chrome blocks animations from running until a screenshot is saved
  is expected to download file "example-org.html"
  is expected to download file "example-org.html"
  is expected to download file "example-org.html"
  is expected to download file "example-org.html"
  is expected to download file "example-org.html"
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
   "html" => "<p class=\"fade-in\"><a href=\"\" download=\"example-org.html\">Download me</a></p>",
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
   "html" => "<p class=\"fade-in\"><a href=\"\" download=\"example-org.html\">Download me</a></p>",
   "opacity" => "1",
   "visibility" => "visible"}}
checkVisibility: base                  true
checkVisibility: contentVisibilityAuto true
checkVisibility: opacityProperty       true
checkVisibility: visibilityProperty    true
  is expected to download file "example-org.html" (FAILED - 1)
```
