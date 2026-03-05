class ProcessInputsJob < ApplicationJob
  queue_as :default

  def perform(input)
    Output.process_input(input)
  end
end
