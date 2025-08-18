classdef SPWMOsc < matlab.System
    %SPWMOsc  Single‑phase Sinusoidal PWM oscillator
    %
    %   frame = osc();                 % returns column vector of ±1 values
    %   All public properties are tunable at run time.
    %

    %% Public, tunable properties
    properties
        ReferenceFrequency  = 440;      % Hz  – fundamental you want
        CarrierFrequency    = 8e3;      % Hz  – triangle switching freq
        ReferenceAmplitude  = 1;        % 0…1 – modulation index
        PhaseOffset         = 0;        % deg – phase lead (+) or lag (–)
        SampleRate          = 48e3;     % Hz  – audio I/O rate
        SamplesPerFrame     = 1024;     % how many you want per call
    end

    %% Private, non‑tunable
    properties (Access = private)
        phRef = 0;                      % running phase (radians)
        phCar = 0;                      % running phase (radians)
    end

    %% Constructor – handles Name/Value pairs
    methods
        function obj = SPWMOsc(varargin)
            if nargin > 0
                setProperties(obj, nargin, varargin{:});   % built‑in helper
            end
        end
    end

    %% Algorithm
    methods (Access = protected)
        function y = stepImpl(obj)
            k  = (0:obj.SamplesPerFrame-1).';              % sample index

            % ---- reference sine with amplitude & phase offset -----------
            phiOff = deg2rad(obj.PhaseOffset);             % convert once
            ref    = obj.ReferenceAmplitude * ...
                     sin(2*pi*obj.ReferenceFrequency/obj.SampleRate * k ...
                         + obj.phRef + phiOff);

            % ---- 50 %‑duty triangle in [‑1, 1] --------------------------
            tri = sawtooth(2*pi*obj.CarrierFrequency/obj.SampleRate * k ...
                           + obj.phCar, 0.5);

            % ---- SPWM comparison → {‑1, +1} -----------------------------
            y = 2*double(ref > tri) - 1;

            % ---- advance phases so next call starts where we left off ---
            dPhiRef = 2*pi*obj.ReferenceFrequency * obj.SamplesPerFrame ...
                      / obj.SampleRate;
            dPhiCar = 2*pi*obj.CarrierFrequency * obj.SamplesPerFrame ...
                      / obj.SampleRate;

            obj.phRef = mod(obj.phRef + dPhiRef, 2*pi);
            obj.phCar = mod(obj.phCar + dPhiCar, 2*pi);
        end
    end
end
