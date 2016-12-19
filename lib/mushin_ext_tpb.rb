require 'mushin'
require_relative 'TPB/version'
require_relative 'TPB/internals'

module TPB
  class Ext 
    using Mushin::Ext 
    include Internal

    attr_accessor :results

    def initialize app=nil, opts={}, params={}
      @app 	= app
      @opts 	= opts
      @params 	= params 
    end
    def call env 
      env ||= Hash.new 
      $log.debug "#{self} ------ Inbound maniuplation"
      env[:query] = @params[:query]
      env[:id] = @params[:query]

      case
      when env[:query].nil?, env[:query].empty?
	p "empty query is no good"
      else 
	results = search(env[:query])
	env[:tpbbot] = results 
      end
      @app.call(env)
      $log.debug "#{self} ------ Outbound maniuplation"
    end
  end
end
