#!/usr/bin/ruby

Pod::Spec.new do |spec|
  spec.name             = "JSONLookup"
  spec.version          = "0.0.1"
  spec.summary          = "Lookup JSON member values with typesafe dynamic member lookup syntax."
  spec.homepage         = "https://github.com/loudmouth/JSONLookup"
  spec.swift_version    = "4.2"

  spec.license = {
      :type => 'MIT',
      :file => 'LICENSE'
  }

  spec.authors      = { "JP Wright" => "jp@contentful.com" }
  spec.source       = { :git => "https://github.com/loudmouth/JSONLookup.git",
                        :tag => spec.version.to_s }
  spec.requires_arc = true

  spec.source_files              = 'Sources/JSONLookup/*.swift'

  spec.ios.deployment_target     = '8.0'
  spec.osx.deployment_target     = '10.10'
  spec.watchos.deployment_target = '2.0'
  spec.tvos.deployment_target    = '9.0'
end


