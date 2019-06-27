# encoding: utf-8
# This file is distributed under New Relic's license terms.
# See https://github.com/newrelic/rpm/blob/master/LICENSE for complete details.

require File.expand_path '../../../../test_helper', __FILE__

module NewRelic
  module Agent
    class Transaction
      class TraceContextTest < Minitest::Test
        def setup
          nr_freeze_time

          @config = {
            #@todo: we need a flag for trace_context enabled, fix sampling
            :'distributed_tracing.enabled' => true,
            :account_id => "190",
            :primary_application_id => "46954",
            :trusted_account_key => "trust_this!"
          }

          NewRelic::Agent.config.add_config_for_testing(@config)
        end

        def teardown
          NewRelic::Agent.config.remove_config(@config)
          NewRelic::Agent.config.reset_to_defaults
          NewRelic::Agent.drop_buffered_data
        end

        def test_insert_trace_context
          nr_freeze_time

          carrier = {}
          trace_state = nil

          t = in_transaction do |txn|
            txn.sampled = true
            txn.insert_trace_context carrier: carrier
            trace_state = txn.trace_state
          end

          expected_trace_parent = "00-#{t.trace_id}-#{t.parent_id}-01"
          assert_equal expected_trace_parent, carrier['traceparent']

          assert_equal trace_state, carrier['tracestate']
        end
      end
    end
  end
end
