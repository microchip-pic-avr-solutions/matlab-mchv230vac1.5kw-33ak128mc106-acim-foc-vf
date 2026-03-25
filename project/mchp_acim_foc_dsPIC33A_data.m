% Model         :   ACIM Control : Sensored FOC with Incremental Encoder | Sensorless FOC | V/F Control
% Description   :   Set Parameters for AC Induction Motor's Field Oriented Control
% File name     :   mchp_acim_foc_dsPIC33A_data.m

%% Simulation Parameters
clc;
clear all;

%% Set PWM Switching frequency
PWM_frequency 	= 20e3;             %Hz // converter s/w freq
T_pwm           = 1/PWM_frequency;  %s  // PWM switching time period

PWM_frequency_mc 	= PWM_frequency;    % Hz // motor control s/w freq
T_pwm_mc            = 1/PWM_frequency_mc;  %s  // PWM switching time period

%% Set Sample Times
Ts          	= T_pwm;         %sec        // Sample time for control system
Ts_mc          	= T_pwm_mc;      %sec
Ts_simulink     = T_pwm_mc;      %sec        // Simulation time step for model simulation
Ts_motor        = T_pwm_mc;      %sec        // Simulation sample time for acim
Ts_inverter     = T_pwm_mc;      %sec        // Simulation time step for inverter
Ts_speed     = T_pwm_mc;      %sec
%% Set data type for controller & code-gen
dataType        = 'single';  

%% System Parameters
% Set motor parameters
acim.model  = 'Leeson_0.33HP';
acim.sn     = 'C4734FB5A';         %          // Manufacturer Model Number
acim.p      = 1;                   %          // Pole Pairs for the motor
acim.Rs     = 7.5;                 %Ohm       // Stator Resistance
acim.Rr     = 3.87;                %Ohm       // Rotor Resistance
acim.Lm     = 0.439;               %H         // Magnetizing inductance
acim.Lls    = 0.0159;              %H         // Stator leakage inductance
acim.Llr    = 0.0159;              %H         // Rotor leakage inductance
acim.J      = 0.000402223;         %
acim.B      = 1e-05;
acim.I_rated = 1.4*sqrt(2);       %A      	// Rated current (phase-peak)
acim.Id0    = 0.79*sqrt(2);
acim.Iq0    = sqrt(acim.I_rated^2 - acim.Id0^2);
acim.V_rated = 230;      %Motor Rated Line - Line RMS Voltage
acim.N_rated = 3450;
acim.N_max = 4000;
acim.Ls = acim.Lls + acim.Lm;
acim.Lr = acim.Llr + acim.Lm;
acim.sigma = 1 -((acim.Lm^2)/(acim.Ls*acim.Lr));
acim.T_rated = 0.01;
acim.QEPSlits = 512;
acim.N_min = 400;

%% Inverter parameters 
% MCHV-230V-1.5kW Development Board 
inverter.model         = 'MCHV-230V-1.5kW';           % 		// Manufacturer Model Number
inverter.sn            = 'INV_XXXX';         		% 		// Manufacturer Serial Number
inverter.V_dc          = 230*sqrt(2);       					%V      // DC Link Voltage of the Inverter
inverter.ISenseMax     = 22.0; 					%Amps   // Max current that can be measured
inverter.I_trip        = 10;                  		%Amps   // Max current for trip
inverter.Rds_on        = 1e-3;                      %Ohms   // Rds ON
inverter.Rshunt        = 0.003;                      %Ohms   // Rshunt
inverter.R_board       = inverter.Rds_on + inverter.Rshunt/3;  %Ohms
inverter.MaxADCCnt     = 4095;      				%Counts // ADC Counts Max Value
inverter.invertingAmp  = -1;                        % 		// Non inverting current measurement amplifier
inverter.deadtime      = 1.5e-6;                      %sec    // Deadtime for the PWM 
inverter.OpampFb_Rf    = 5e3;                    %Ohms   // Opamp Feedback resistance for current measurement
inverter.opampInput_R  = 200;                       %Ohms   // Opamp Input resistance for current measurement
inverter.opamp_Gain    = inverter.OpampFb_Rf/inverter.opampInput_R; % // Opamp Gain used for current measurement

%Updating delays for simulation
PI_params_SI.delay_Currents    = int32(Ts_mc/Ts_simulink);
PI_params_SI.delay_Position    = int32(Ts_mc/Ts_simulink);
PI_params_SI.delay_Speed       = int32(Ts_speed/Ts_simulink);

%% PI parameters
PI_params_SI.Kp_i = 69.68;
PI_params_SI.Ki_i = 16660;
PI_params_SI.Kp_speed = 0.001;
PI_params_SI.Ki_speed = 0.0050;

PI_params_SI.Kp_FW = 0.001*4;
PI_params_SI.Ki_FW = 0.00000024*4;

%% Control scheme parameters
CS_param.SpeedRampRate = 0.02;
CS_param.currentRampRate = 0.05;
CS_param.DCBusUtilFactor = 0.9;
CS_param.VmaxPhase = CS_param.DCBusUtilFactor*inverter.V_dc/sqrt(3);
CS_param.VbyF_constant = ( sqrt(2.0/3.0)*(acim.V_rated-0)/(acim.N_rated)) ;
CS_param.OLTSpeed = 60.0*3/acim.p;

%% Estimator parameters
SpeedFilterCutoff = 40;
estim_pll.decimateSpeedBEMF = 60.0 * 4/acim.p ;
estim_qei.tau_TL = 0.0009;
estim_qei.zeta_TL = 1;

%% Serial Communication for Debugging

Ts_serialIn     = 100e-3;
Ts_serialOut    = 500e-6;

target.frameSize = 120;
target.comport = 'COM4';
target.BaudRate = 1000000;
