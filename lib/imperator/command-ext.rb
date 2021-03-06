class Imperator::Command
  # the main object this command works on
  attribute :object, Object

  # object that initiated the command. 
  # Can be used for method delegation etc
  attribute :initiator, Object 

  def to_s
    str = "Command: #{id}"
    str << " - #{object}" if object
    str
  end
end  
