function [] = livePlot(app,output,output2,input,input2,endTime,i,lastEndTime)

switch i

    case 0
        Time = lastEndTime:(endTime-lastEndTime)/(length(output2)-1):endTime;
    plot(app.ResultsPlot,Time,output,'b-',Time,input,'k--')
    ylim(app.ResultsPlot,[-1,1])

    plot(app.ResultsPlot2,Time,output2,'b-',Time,input2,'k--')
    ylim(app.ResultsPlot2,[-1,1])

    xlim(app.ResultsPlot2,[lastEndTime,endTime])
    xlim(app.ResultsPlot,[lastEndTime,endTime])

    case 1
    transOutput = output - mean(output);
    transOutput2 = output2 - mean(output2);

    dt = (endTime-lastEndTime)/(length(output2)-1);
    intOutput = cumsum(transOutput)*dt;
    intOutput2 = cumsum(transOutput2)*dt;

    samplesPerWaveform = 192000/(app.startFreq);                    % Bug - If samplesPerWaveform > total samples recorded, BH curve is not plotted
    bhOutput = intOutput-movmean(intOutput,samplesPerWaveform);
    bhOutput2 = intOutput2-movmean(intOutput2,samplesPerWaveform);

    plot(app.BHCurve,bhOutput2(round(samplesPerWaveform/2):end-round(samplesPerWaveform/2)),bhOutput(round(samplesPerWaveform/2):end-round(samplesPerWaveform/2)))


    case 2
    Time = lastEndTime:(endTime-lastEndTime)/(length(output2)-1):endTime;
    transOutput = output - mean(output);
    transOutput2 = output2 - mean(output2);

    dt = (endTime-lastEndTime)/(length(output2)-1);
    intOutput = cumsum(output)*dt;
    intOutput2 = cumsum(output2)*dt;

    plot(app.ProcessedWaveforms4,Time,transOutput,'k-')
    ylim(app.ProcessedWaveforms4,[-1 1])
    xlim(app.ProcessedWaveforms4,[lastEndTime endTime])

    plot(app.ProcessedWaveforms3,Time,transOutput2,'k-')
    ylim(app.ProcessedWaveforms3,[-1 1])
    xlim(app.ProcessedWaveforms3,[lastEndTime endTime])

    plot(app.ProcessedWaveforms2,Time,intOutput,'k-')
    xlim(app.ProcessedWaveforms2,[lastEndTime endTime])

    plot(app.ProcessedWaveforms,Time,intOutput2,'k-')
    xlim(app.ProcessedWaveforms,[lastEndTime endTime])
end
end
