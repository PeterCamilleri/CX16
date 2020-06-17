#Test the Sweet-16 Virtual Machine

Test65.script do

  ca65 "test_sweet_16.a65"
  ca65 "../SW16/sweet_16.a65", "-D sw16_sim_support"

  ld65
  sim65

end
