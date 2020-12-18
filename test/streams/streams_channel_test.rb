require "turbo_test"
require "action_cable"

ActionCable.server.config.logger = Logger.new(STDOUT) if ENV["VERBOSE"]

class Turbo::StreamsChannelTest < ActionCable::Channel::TestCase
  include ActiveJob::TestHelper

  test "verified stream name" do
    assert_equal "stream", Turbo::StreamsChannel.verified_stream_name(Turbo::StreamsChannel.signed_stream_name("stream"))
  end


  test "broadcasting remove now" do
    assert_broadcast_on "stream", %(<turbo-stream action="remove" target="message_1"></turbo-stream>) do
      Turbo::StreamsChannel.broadcast_remove_to "stream", element: "message_1"
    end
  end

  test "broadcasting remove now with record" do
    assert_broadcast_on "stream", %(<turbo-stream action="remove" target="message_1"></turbo-stream>) do
      Turbo::StreamsChannel.broadcast_remove_to "stream", element: Message.new(1)
    end
  end

  test "broadcasting replace now" do
    assert_broadcast_on "stream", %(<turbo-stream action="replace" target="message_1"><template><p>hello!</p></template></turbo-stream>) do
      Turbo::StreamsChannel.broadcast_replace_to "stream", element: "message_1", partial: "messages/message", locals: { message: "hello!" }
    end
  end

  test "broadcasting append now" do
    assert_broadcast_on "stream", %(<turbo-stream action="append" target="messages"><template><p>hello!</p></template></turbo-stream>) do
      Turbo::StreamsChannel.broadcast_append_to "stream", container: "messages", partial: "messages/message", locals: { message: "hello!" }
    end
  end

  test "broadcasting prepend now" do
    assert_broadcast_on "stream", %(<turbo-stream action="prepend" target="messages"><template><p>hello!</p></template></turbo-stream>) do
      Turbo::StreamsChannel.broadcast_prepend_to "stream", container: "messages", partial: "messages/message", locals: { message: "hello!" }
    end
  end

  test "broadcasting action now" do
    assert_broadcast_on "stream", %(<turbo-stream action="prepend" target="messages"><template><p>hello!</p></template></turbo-stream>) do
      Turbo::StreamsChannel.broadcast_action_to "stream", action: "prepend", dom_id: "messages", partial: "messages/message", locals: { message: "hello!" }
    end
  end


  test "broadcasting replace later" do
    assert_broadcast_on "stream", %(<turbo-stream action="replace" target="message_1"><template><p>hello!</p></template></turbo-stream>) do
      perform_enqueued_jobs do
        Turbo::StreamsChannel.broadcast_replace_later_to \
          "stream", element: "message_1", partial: "messages/message", locals: { message: "hello!" }
      end
    end
  end

  test "broadcasting append later" do
    assert_broadcast_on "stream", %(<turbo-stream action="append" target="messages"><template><p>hello!</p></template></turbo-stream>) do
      perform_enqueued_jobs do
        Turbo::StreamsChannel.broadcast_append_later_to \
          "stream", container: "messages", partial: "messages/message", locals: { message: "hello!" }
      end
    end
  end

  test "broadcasting prepend later" do
    assert_broadcast_on "stream", %(<turbo-stream action="prepend" target="messages"><template><p>hello!</p></template></turbo-stream>) do
      perform_enqueued_jobs do
        Turbo::StreamsChannel.broadcast_prepend_later_to \
          "stream", container: "messages", partial: "messages/message", locals: { message: "hello!" }
      end
    end
  end

  test "broadcasting action later" do
    assert_broadcast_on "stream", %(<turbo-stream action="prepend" target="messages"><template><p>hello!</p></template></turbo-stream>) do
      perform_enqueued_jobs do
        Turbo::StreamsChannel.broadcast_action_later_to \
          "stream", action: "prepend", dom_id: "messages", partial: "messages/message", locals: { message: "hello!" }
      end
    end
  end


  test "broadcasting render now" do
    assert_broadcast_on "stream", %(<turbo-stream action="replace" target="message_1"><template>Goodbye!</template></turbo-stream>) do
      Turbo::StreamsChannel.broadcast_render_to "stream", partial: "messages/message"
    end
  end

  test "broadcasting render later" do
    assert_broadcast_on "stream", %(<turbo-stream action="replace" target="message_1"><template>Goodbye!</template></turbo-stream>) do
      perform_enqueued_jobs do
        Turbo::StreamsChannel.broadcast_render_later_to "stream", partial: "messages/message"
      end
    end
  end

  test "broadcasting update now" do
    assert_broadcast_on "stream", %(direct) do
      Turbo::StreamsChannel.broadcast_update_to "stream", content: "direct"
    end
  end
end