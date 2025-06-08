FROM ruby:3.4.4-alpine

RUN apk add --update chromium chromium-chromedriver

WORKDIR /home/chrome-downloads-block-css-animations

COPY spec_helper.rb .
COPY chrome_no_animation_until_screenshot_spec.rb .

CMD ["ruby", "chrome_no_animation_until_screenshot_spec.rb"]
