class TestLoggerFormatter
  RSpec::Core::Formatters.register(
    self,
    :example_started,
    :example_passed,
    :example_failed,
    :example_pending,
    :dump_summary
  )

  def initialize(output)
    @output = output
  end

  def example_started(notification)
    example = notification.example
    @output.puts "[TEST] WHAT: #{example.full_description}"
    @output.puts "[TEST] PROCESS: #{example.location}"
  end

  def example_passed(notification)
    @output.puts "[TEST] RESULT: PASS"
  end

  def example_failed(notification)
    @output.puts "[TEST] RESULT: FAIL"
  end

  def example_pending(notification)
    @output.puts "[TEST] RESULT: PENDING"
  end

  def dump_summary(summary)
    @output.puts "[TEST] SUMMARY: #{summary.example_count} examples, #{summary.example_count - summary.failure_count} passed, #{summary.failure_count} failures"
  end
end
