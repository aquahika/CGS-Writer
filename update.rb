#!/usr/bin/env ruby

Dir.chdir(File.dirname(__FILE__)) do
	`git fetch origin`
	`git reset --hard origin/master`
#	`touch a`
end