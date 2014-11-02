xml.instruct!
xml.Response do
  xml.Say "Hi #{@name}, you’re booked for a pensions guidance session on #{@time}. A pensions expert will call you on this number.", voice: 'alice', language: 'en-GB'
end
