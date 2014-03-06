Slide'em up
===========

This fork of Slide'em up is specialized for the use case of the Nashville Software School syllabus repositories, which are all markdown files.

I want the markdown to be readable and usable in github, plain-text, and in a presentation format.

Thus, I've made the following changes:

1. `slide-em-up` takes an argument of a single markdown file to render.
2. '#' (the h1) is the title of the presentation
3. '##' (the h2) is the section title delimeter.
4. '~~~' or a new section title ('##') is the slide delimeter

See the original repository at https://github.com/nono/slide-em-up for the general README.

To use my fork, you can add it to your Gemfile as such:

  gem 'slide-em-up', github: "elizabrock/slide-em-up", branch: 'master'

Then, run it with `slide-em-up mypresentation.md`


## Credits:

Slide 'em up forked from: https://github.com/nono/slide-em-up

Theme based on: https://github.com/rmcgibbo/slidedeck
