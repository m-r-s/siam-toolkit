#!/usr/bin/octave

% Example measurement
%
% Copyright (C) 2019 Marc René Schädler
% E-mail: marc.r.schaedler@uni-oldenburg.de

close all
clear
clc

% SIAM config
target = 0.75;
minreversals = 14;
discardreversals = 4;
minmeasures = 25;
startvalue = 0;
steps = [8 8 4 2];
feedback = 1;

% Set up measurement
function noise_offset = presentstimulus(presentation, value)
  if presentation > 0
    present_value = 100;
  else
    present_value = -100;
  end
  noise_offset = randn(1).*10.^(-value/20);
  present_value = present_value + noise_offset;
  printf('   | Is the true value higher than 0? %.2f\n',present_value);
end

function answer = getanswer(count)
  validanswer = 0;
  while validanswer == 0
    answer = input(sprintf('%3i|  1) yes  0) no  a) abort  -->  ',count),'s');
    switch tolower(answer)
      case {'0', '1'}
        validanswer = 1;
      case {'a'}
        validanswer = 2;
    end
  end
  switch validanswer
    case 1
      answer = str2num(answer);
    case 2
      exit
  end
end

% Perform measurement
[threshold, values, reversals, measures, presentations, answers, adjustments] =...
  siam(@presentstimulus, @getanswer, target, minreversals, discardreversals, minmeasures, startvalue, steps, feedback);

% Print some data of the run
figure('Position',[0 0 300 300]);
set(gcf,'PaperUnits','inches','PaperPosition',[0 0 3 3].*1.4);

x = 1:length(values);
plot(x,values,'-k');
xlabel('Presentation number');
ylabel('Value');
hold on;

if ~isempty(threshold) && ~isnan(threshold)
  plot(x([1 end]),[1 1].*threshold,'Color',[0 1 0].*0.8,'LineWidth',2);
end

xi = measures==0 & reversals==0;
if ~isempty(xi)
  plot(x(xi),values(xi),'o','Color',[1 1 1].*0.5);
end
xi = measures==1 & reversals==0;
if ~isempty(xi)
  plot(x(xi),values(xi),'o','Color',[1 0 0].*0.8);
end

xi = measures==0 & reversals>0;
if ~isempty(xi)
  plot(x(xi),values(xi),'^','Color',[1 1 1].*0.65,'MarkerSize',10);
end
xi = measures==1 & reversals>0;
if ~isempty(xi)
  plot(x(xi),values(xi),'^','Color',[0 1 1].*0.65,'MarkerSize',10);
end

xi = measures==0 & reversals<0;
if ~isempty(xi)
  plot(x(xi),values(xi),'v','Color',[1 1 1].*0.65,'MarkerSize',10);
end
xi = measures==1 & reversals<0;
if ~isempty(xi)
  plot(x(xi),values(xi),'v','Color',[0 1 1].*0.65,'MarkerSize',10);
end

axis tight;
grid on;  
print('-depsc2', '-r300', 'last_example_run.eps');
  
