function [] = dataAnalysis(app,output,output2,input,input2,endTime,lastEndTime)
try

    % Main waveform plots
    app.Time = lastEndTime:endTime/(length(output2)-1):endTime;
    plot(app.ResultsPlot,app.Time,output,'b-',app.Time,input,'k--')
    % legend(app.ResultsPlot,{'Recorded Wave','Transmit Wave'})
    ylim(app.ResultsPlot,[-1,1])

    plot(app.ResultsPlot2,app.Time,output2,'b-',app.Time,input2,'k--')
    % legend(app.ResultsPlot2,{'Recorded Wave','Transmit Wave'})
    ylim(app.ResultsPlot2,[-1,1])

    % if endTime-(1/app.startFreq) <= 0
        % xlim(app.ResultsPlot2,[0,endTime])
        % xlim(app.ResultsPlot,[0,endTime])
    % else
    %     xlim(app.ResultsPlot2,[endTime-(1/app.startFreq),endTime])
    %     xlim(app.ResultsPlot,[endTime-(1/app.startFreq),endTime])
    % end

    % FFT of first channel

    X1 = fft(output);
    X2 = fft(input);

    [~, idx] = max(abs(X1));

    X1_peak = X1(idx);
    X2_peak = X2(idx);

    mag_diff_dB = 20*log10(abs(X2_peak) / abs(X1_peak));

    phase_diff_deg = angle(X2_peak / X1_peak) * (180/pi);

    if phase_diff_deg <= 0
        phase_diff_time = ((1/(app.startFreq))*((360+phase_diff_deg)/360))*1000;
    else
        phase_diff_time = ((1/(app.startFreq))*((phase_diff_deg)/360))*1000;
    end

    % FFT of second channel

    X1 = fft(output2);
    X2 = fft(input2);

    [~, idx] = max(abs(X1));

    X1_peak = X1(idx);
    X2_peak = X2(idx);

    mag_diff_dB2 = 20*log10(abs(X2_peak) / abs(X1_peak));

    phase_diff_deg2 = angle(X2_peak / X1_peak) * (180/pi);

    if phase_diff_deg2 <= 0
        phase_diff_time2 = ((1/(app.startFreq))*((360+phase_diff_deg2)/360))*1000;
    else
        phase_diff_time2 = ((1/(app.startFreq))*((phase_diff_deg2)/360))*1000;
    end

    % Transformed & integrated outputs
    transOutput = output - mean(output);
    transOutput2 = output2 - mean(output2);


    dt = endTime/(length(output2)-1);
    intOutput = cumsum(transOutput)*dt;
    intOutput2 = cumsum(transOutput2)*dt;


    % Shows Results in UI
    app.ResultsLabel.Text = ['Channel 1 Results -', newline, ...
        'Magnitude Difference: ', num2str(mag_diff_dB), ' dB', newline, ...
        'Phase Difference: ', num2str(phase_diff_deg), ' deg', newline, ...
        'Phase Difference: ', num2str(phase_diff_time), ' ms', newline, ...
        'CH1 RMS Value: ', num2str(rms(transOutput)), ' V', newline, ...
        newline, ...
        'Channel 2 Results -', newline, ...
        'Magnitude Difference: ', num2str(mag_diff_dB2), ' dB', newline, ...
        'Phase Difference: ', num2str(phase_diff_deg2), ' deg', newline, ...
        'Phase Difference: ', num2str(phase_diff_time2), ' ms', newline, ...
        'CH2 RMS Value: ', num2str(rms(transOutput2)), ' V', newline, ...
        newline, ...
        'Mean of CH1*CH2: ' num2str(mean(transOutput.*transOutput2))];

    % Plot transformed and integrated waveforms
    plot(app.ProcessedWaveforms4,app.Time,transOutput,'k-')
    ylim(app.ProcessedWaveforms4,[-1 1])
    xlim(app.ProcessedWaveforms4,[0 endTime])

    plot(app.ProcessedWaveforms3,app.Time,transOutput2,'k-')
    ylim(app.ProcessedWaveforms3,[-1 1])
    xlim(app.ProcessedWaveforms3,[0 endTime])

    plot(app.ProcessedWaveforms2,app.Time,intOutput,'k-')
    xlim(app.ProcessedWaveforms2,[0 endTime])

    plot(app.ProcessedWaveforms,app.Time,intOutput2,'k-')
    xlim(app.ProcessedWaveforms,[0 endTime])

    % BH Curve plotting

    samplesPerWaveform = 192000/(app.startFreq);                    % Bug - If samplesPerWaveform > total samples recorded, BH curve is not plotted
    bhOutput = intOutput-movmean(intOutput,samplesPerWaveform);
    bhOutput2 = intOutput2-movmean(intOutput2,samplesPerWaveform);

    % plot(app.BHCurve,bhOutput(round(samplesPerWaveform/2):end-round(samplesPerWaveform/2)),bhOutput2(round(samplesPerWaveform/2):end-round(samplesPerWaveform/2)))
    plot(app.BHCurve,bhOutput2(round(samplesPerWaveform/2):end-round(samplesPerWaveform/2)),bhOutput(round(samplesPerWaveform/2):end-round(samplesPerWaveform/2)))
    drawnow

catch ME
    logMessage(app,['Error within dataAnalysis function! - ', ME.message])
end
end