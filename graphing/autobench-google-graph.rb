# Used to graph results from autobench
#
# Usage: ruby autobench_grapher.rb result_from_autobench.tsv
#
# This will generate three svg & png graphs

require "rubygems"
#require "scruffy"
require "google_chart"
require 'gchart'
require 'csv'
require 'yaml'

class ResultGrapher

  def self.run
    new(ARGV.first).run
  end

  def initialize(result_file)
    @result_file = result_file
    @stats = {
      :attempted_request_rate => [], 
      :average_reply_rate => [], 
      :average_response_time => [], 
      :errors => []
    }
  end

  def run 
    parse_log
    generate_google_graph
    #puts @stats.inspect
  end

  def parse_log
    File.open(@result_file).each do |line|
      row = line.split("\t") 

      next if row[0] =~ /^\D+/

      @stats[:attempted_request_rate] << row[0].to_f
      @stats[:average_reply_rate] << row[4].to_f
      @stats[:average_response_time] << row[7].to_f
      @stats[:errors] << row[9].to_f
    end
  end
  
  def file_root
    @result_file.gsub(/\..*/, "")
  end

  def generate_google_graph

    #Line XY Chart
    line_chart_xy = GoogleChart::LineChart.new('600x400', "Performance Results", true) do |lcxy|
      lcxy.show_legend = true
      reply_rate_data = @stats[:attempted_request_rate].zip(@stats[:average_reply_rate])
      response_time_data = @stats[:attempted_request_rate].zip(@stats[:average_response_time])

      lcxy.data "Averate Reply Rate", reply_rate_data, 'FF0000'
      lcxy.data "Average Response Time", response_time_data, '000BFF'
      lcxy.axis :x, :range => [0,500]
      lcxy.axis :y, :range => [0,2000]
      puts lcxy.to_url   
    end


  end


  def generate_graph
    g = Scruffy::Graph.new
    g.title = "Average Reply Rate (Responses per Second)"
    g.renderer = Scruffy::Renderers::Standard.new

    g.add :area, "Attempted Request Rate", @stats[:attempted_request_rate]
    g.add :line, "Average Reply Rate", @stats[:average_reply_rate]

    g.point_markers = @stats[:attempted_request_rate]

    g.render :to => "#{file_root}_average_reply_rate.svg"
    g.render  :to => "#{file_root}_average_reply_rate.png", :as => 'png'
      #:width => 1500, :height => 1000,
    

    g2 = Scruffy::Graph.new
    g2.title = "Average Response Time (in ms)"
    g2.renderer = Scruffy::Renderers::Standard.new

    g2.add :line, "Average Response Time", @stats[:average_response_time]

    g2.point_markers = @stats[:attempted_request_rate]
    
    g2.render :to => "#{file_root}_average_response_time.svg"
    g2.render  :to => "#{file_root}_average_response_time.png", :as => 'png'# :width => 1500, :height => 1000,
   

    g3 = Scruffy::Graph.new
    g3.title = "Errors"
    g3.renderer = Scruffy::Renderers::Standard.new

    g3.add :line, "Errors", @stats[:errors]
    
    g3.point_markers = @stats[:attempted_request_rate]

    g3.render :to => "#{file_root}_errors.svg"
    g3.render :to => "#{file_root}_errors.png", :as => 'png'# :width => 1500, :height => 1000,
    
    
  end
end

ResultGrapher.run