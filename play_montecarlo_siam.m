#!/usr/bin/octave

% Monte-Carlo simulation of SIAM procedure
%
% Copyright (C) 2019 Marc René Schädler
% E-mail: marc.r.schaedler@uni-oldenburg.de

close all
clear
clc
graphics_toolkit qt

figure_path = 'figures';

% Adapt config
target = 0.75;
minreversals = 14;
discardreversals = 4;
minmeasures = 25;
startvalue = 20;
steps = [4 4 2 1];
feedback = 0;

% Simulation config
L_50s = [-10 0 10];
s_50s = [0.10 0.125 0.150];
p = [0.5 1];
N = 1000;
showfigure = false;

% Allocate memory
thresholds = nan(numel(s_50s),numel(L_50s),N);
numpresentations = zeros(numel(s_50s),numel(L_50s),N);

for is=1:length(s_50s)
  for il=1:length(L_50s)
    printf('Simulating threshold %f  slope %f\n', L_50s(il), s_50s(is));
    % Initialize virtual answerer
    virtualanswerer([], [], [], L_50s(il), s_50s(is), p);
    presentstimulus = @(presentation,value) presentation;
    for in=1:N
      [threshold, values, reversals, measures, presentations, answers, adjustments] =...
        siam(presentstimulus, @virtualanswerer, target, minreversals, discardreversals, minmeasures, startvalue, steps, feedback);
      if showfigure || threshold < -20
        x = 1:length(values);
        plot(values,'-k');
        xlabel('Presentation number');
        ylabel('Value');
        hold on;
        xi = measures==0 & reversals==0;
        h(1) = plot(x(xi),values(xi),'o','Color',[1 1 1].*0.5);
        xi = measures==1 & reversals==0;
        h(3) = plot(x(xi),values(xi),'o','Color',[1 0 0].*0.8);
        xi = measures==0 & reversals>0;
        h(2) = plot(x(xi),values(xi),'^','Color',[1 1 1].*0.5,'MarkerSize',10);
        xi = measures==1 & reversals>0;
        h(4) = plot(x(xi),values(xi),'^','Color',[0 1 1].*0.5,'MarkerSize',10);
        xi = measures==0 & reversals<0;
        plot(x(xi),values(xi),'v','Color',[1 1 1].*0.5,'MarkerSize',10);
        xi = measures==1 & reversals<0;
        plot(x(xi),values(xi),'v','Color',[0 1 1].*0.5,'MarkerSize',10);
        h(5) = plot(x([1 end]),[1 1].*threshold,'Color',[0 1 0].*0.8,'LineWidth',2);
        axis tight;
        drawnow;   
        hold off;
        ylim([-30 30]);
        pause;
      end
      printf('.');
    thresholds(is,il,in) = threshold;
    numpresentations(is,il,in) = length(values);
    end
    printf('\n');
  end
end

if any(isnan(thresholds))
  disp('There were unsuccessful measurements');
end

means = mean(thresholds,3)
stds = std(thresholds,[],3)
avgnumpresentations = mean(numpresentations,3)


pos = [0 0 1000 1000/length(s_50s)];
figure('Position', pos);
set(gcf, 'PaperUnits', 'inches', 'PaperPosition', pos./70);
subplot = @(m,n,p) axes('Position',subposition(m,n,p))

% Calculate the true thresholds
true_values = zeros(length(s_50s),length(L_50s));
for is=1:length(s_50s)
  for il=1:length(L_50s)
    threshold = (p(1)+(p(2)-p(1)).*target);
    true_values(is,il) = ...
       fminsearch(@(x) abs(sigmoid(x, L_50s(il), s_50s(is), p) - threshold), mean(p));
  end
end

for is=1:length(s_50s)
  subplot(1,length(s_50s),is);
  plot([-15 15],[-15 15],'-.k');
  hold on;
  axis image;
  xlabel('True threshold [dB]');
  ylabel('Measured threshold (mean) [dB]');
  errorbar(true_values(is,:),means(is,:),stds(is,:));
  for il=1:length(L_50s)
    text(true_values(is,il),means(is,il),num2str(avgnumpresentations(is,il)))
  end
  hold on;
  title(sprintf('slope: %.1f %%/dB (before scaling)',s_50s(is)*100))
end
mkdir(figure_path);
print('-dpng','-r300',[figure_path filesep 'montecarlo_siam.png']);
