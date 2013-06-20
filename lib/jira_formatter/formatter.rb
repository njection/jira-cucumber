require "jira_formatter/version"
require 'jira_formatter/jira_interface'

module JiraFormatter
  #responds to the cucumber formatter methods and parses the relevant information
  class Formatter
    def initialize(step_mother, io, options)
      @step_mother, @io, @options = step_mother, io, options
    end
    
    def after_features(*args)
      @scenarios = failed_and_passed
      JiraInterface.new.report(format_scenarios)
    end
    
    private
    
    def failed_and_passed
      failures = @step_mother.scenarios(:failed).select { |s|
        s.is_a?(Cucumber::Ast::Scenario) || s.is_a?(Cucumber::Ast::OutlineTable::ExampleRow) }
      passes = @failures = @step_mother.scenarios(:passed).select { |s| s.is_a?(Cucumber::Ast::Scenario) || s.is_a?(Cucumber::Ast::OutlineTable::ExampleRow) }
      return failures + passes
    end

    def format_scenarios
      @scenarios.map do |scenario|
        properties = Hash.new()
        properties[:run_time] = Time.new()
        properties[:tags] = scenario.source_tag_names

        properties[:status] = scenario.status
        properties[:domain] = determine_domain(scenario)
        if properties[:status] == :failed
          
        end

        if scenario.class == Cucumber::Ast::Scenario
          properties.merge build_from_scenario(scenario)
        elsif scenario.class == Cucumber::Ast::OutlineTable::ExampleRow
          properties.merge build_from_example_row(scenario)
        end
      end
    end

    def determine_domain(scenario)

    end

    def build_from_scenario(scenario)
      {
          :feature => scenario.feature.name,
          :scenario => scenario.name
      }
    end

    def build_from_example_row(example_row)
      {
          :feature => example_row.scenario_outline.feature.name,
          :scenario => example_row.scenario_outline.name
      }
    end    
  end
end