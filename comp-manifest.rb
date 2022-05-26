#!/usr/bin/env ruby

# Copyright (C) 2022 hidenorly
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'fileutils'
require 'rexml/document'
require 'optparse'

class RepoUtil
	DEF_MANIFESTFILE = "/.repo/manifest.xml"
	DEF_MANIFESTFILE2 = "/.repo/manifests/default.xml"

	def self.getPathesFromManifest(basePath)
		pathes = []
		manifestPath = basePath + DEF_MANIFESTFILE
		manifestPath = basePath + DEF_MANIFESTFILE2 if FileTest.exist?(basePath + DEF_MANIFESTFILE2)

		if FileTest.exist?(manifestPath) then
			doc = REXML::Document.new(open(manifestPath))
			doc.elements.each("manifest/project[@name]") do |anElement|
				pathes << anElement.attributes["name"]
			end
		end

		return pathes
	end
end

class RepoOperator
	def self.findNextOperator(operations, startPos)
		result = nil
		i = startPos
		endPos = operations.length

		while i<endPos
			if operations[i].match(/[0-9]/)==nil then
				result = i
				break
			end
			i=i+1
		end
		return result
	end

	def self.execOperation(argA, argB, operation)
		case operation
		when "+"
			return argA + argB
		when "-"
			return argA - argB
		when "&"
			return argA & argB
		end

		return nil # invalid operarion
	end

	def self.execOperations(operations, repos)
		result = repos[ operations[0].to_i-1 ]
		i = 1
		endPos = operations.length

		while i<endPos
			operationPos = findNextOperator(operations, i)
			break if !operationPos
			result = execOperation( result, repos[ operations[operationPos+1].to_i-1 ], operations[operationPos] )
			i = operationPos+1
		end

		return result
	end
end

#---- main --------------------------
operation = "2 - 1"

opt_parser = OptionParser.new do |opts|
	opts.banner = "Usage: [operation(default:\"#{operation}\")] <origin home dir(1)> <target home dir(2)> [<..>]\n#{__FILE__} \"2 - 1\" ~/work/s ~/work/master"
end.parse!

# arg check
if (ARGV.length < 2) then
	puts opt_parser
	exit(-1)
end

# operation
repos = []
startPos = 0
if ARGV.length > 2 then
	operation = ARGV[0].to_s.upcase
	startPos = 1
end
for i in startPos..ARGV.length - 1 do
	if FileTest.directory?( ARGV[i] ) then
		repos << RepoUtil.getPathesFromManifest( ARGV[i] )
	else
		puts ".repo/manifest.xml is not found in #{ARGV[i]}"
		exit(-1)
	end
end
	
puts RepoOperator.execOperations(operation.split(" "), repos)
