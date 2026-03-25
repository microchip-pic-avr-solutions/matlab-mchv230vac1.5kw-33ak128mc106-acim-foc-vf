classdef appState < Simulink.IntEnumType
  enumeration
    INIT(0)
    OFFSET_MEAS(1)
    CMD_WAIT(2)
    VF_OPEN_LOOP(3)
    FOC_CLOSED_LOOP(4)
    STOP(5)
  end
end