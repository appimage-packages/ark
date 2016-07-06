#!/usr/bin/env ruby
# frozen_string_literal: true
# 
# Copyright (C) 2016 Scarlett Clark <sgclark@kde.org>
# Copyright (C) 2015-2016 Harald Sitter <sitter@kde.org>
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) version 3, or any
# later version accepted by the membership of KDE e.V. (or its
# successor approved by the membership of KDE e.V.), which shall
# act as a proxy defined in Section 6 of version 3 of the license.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library.  If not, see <http://www.gnu.org/licenses/>.

#attempt to get deps. NOTE: This is for ubuntu/debian based distro
require 'fileutils'
require_relative 'generate_recipe.rb'

appimage = Recipe.new
appimage.name = "ark"
cmake_deps = ''
appimage.dependencies = []
if not File.exists?("#{appimage.name}")
    system("git clone http://anongit.kde.org/#{appimage.name}
 #{appimage.name}")
    Dir.chdir("#{appimage.name}") do
    system("git submodule init")
    system("git submodule update") 
end
FileUtils.cp('cmake-dependencies.py', "#{appimage.name}")
Dir.chdir("#{appimage.name}") do
    system("cmake \
    -DCMAKE_INSTALL_PREFIX:PATH=/app/usr/ \
    -DCMAKE_BUILD_TYPE=RelWithDebInfo \
    -DPACKAGERS_BUILD=1 \
    -DBUILD_TESTING=FALSE"
    )
    system("make -j8")
    cmake_deps = `python3 cmake-dependencies.py | grep '\"project\": '`.sub('\\', '').split(',')
end

cmake_deps.each do |dep|
    parts = dep.sub('{', '').sub('}', '').split(',')

    parts.each do |project|        
        a = project.split.each_slice(3).map{ |x| x.join(' ')}.to_s
        if a.to_s.include? "project"
            name = a.gsub((/[^0-9a-z ]/i), '')
            name.slice! "project "
            appimage.dependencies.push name            
        end
    end
end

puts appimage.dependencies
