simple live coding
===============

This is a proof of concept for a live drawing app in Ruby with
the [Ruby-Processing Gem (based on processing-2.0.1, and jruby-1.7.4)](https://github.com/monkstone/ruby-processing)

Get inspired by [Bret Victor](http://worrydream.com/#!/LearnableProgramming) or join the project with your own idea..

![drawing from a 6 year old girl](http://i43.tinypic.com/15n8x9v.jpg)
This drawing was made from a 6 year old girl at the CoderDojo cologne...

There is a stand alone app to play with without need of installing all stuff.
With "ellipse 50 50 80 80" or "rect/line/fill" you can draw and with mouse dragging change the values.


Notice
===============

Start Ruby-Processing with "rp5 watch simple_live_coding.rb". This reloads "simple_live_coding.rb" after safing and you can implement your ideas in this file
without need to restart. After implementation of the new feature just copy your code in a seperate file in the "main" directory and do "require_relative" for the file.

This is live coding a live coding app...