require "spec_helper"

RSpec.describe Lita::Handlers::Updates, :lita_handler => true do
  it "runs through the standup flow" do
    send_command "standup", :privately => true

    expect(replies.last).to include("time for our standup meeting")

    send_message "many things", :privately => true

    expect(replies.last).to include("What are you working on next?")

    send_message "other things", :privately => true

    expect(replies.last).to include("What blockers")

    send_message "nothing much", :privately => true

    expect(replies.last).to include("Test User posted a status update")
    expect(replies.last).to include("What have you just been working on?")
  end

  it "skips answers of None" do
    send_command "standup", :privately => true

    expect(replies.last).to include("time for our standup meeting")

    send_message "None", :privately => true

    expect(replies.last).to include("What are you working on next?")

    send_message "other things", :privately => true

    expect(replies.last).to include("What blockers")

    send_message "nothing much", :privately => true

    expect(replies.last).to_not include("What have you just been working on?")
  end

  it "skips sharing when cancelled" do
    send_command "standup", :privately => true

    expect(replies.last).to include("time for our standup meeting")

    send_message "many things", :privately => true

    expect(replies.last).to include("What are you working on next?")

    send_message "Cancel", :privately => true

    expect(replies.last).to_not include("What blockers")
    expect(replies.last).to_not include("Test User posted a status update")
  end

  it "allows for scheduling of standups" do
    send_command "standup schedule 12:00 monday friday", :privately => true

    expect(replies.last).
      to include("Standup scheduled for 12:00 on monday, friday")
  end

  it "allows for clearing of schedules" do
    send_command "standup schedule 12:00 monday friday", :privately => true
    send_command "standup schedule clear", :privately => true

    expect(replies.last).to include("No standup scheduled")
  end

  it "reports on the current schedule" do
    send_command "standup schedule", :privately => true

    expect(replies.last).to include("No standup scheduled")
  end

  it "can export schedules" do
    send_command "standup schedule 12:00 monday friday", :privately => true
    send_command "standup export", :privately => true

    expect(replies.last).to include(
      JSON.dump(
        "Test User" => {"time" => "12:00", "days" => ["monday", "friday"]}
      )
    )
  end

  it "can import schedules" do
    json = JSON.dump(
      "Test User" => {"time" => "12:00", "days" => ["monday", "friday"]}
    )

    send_command "standup import #{json}", :privately => true
    send_command "standup schedule", :privately => true

    expect(replies.last).
      to include("Standup scheduled for 12:00 on monday, friday")
  end
end
