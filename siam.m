function [threshold, values, reversals, measures, presentations, answers, adjustments, offsets] =...
  siam(presentationhandle, answerhandle, target, minreversals, discardreversals, minmeasures, startvalue, steps, feedback)

% Implementation of the single-interval adjustment-matrix procedure (SIAM) as proposed by [1]
%
% Copyright (C) 2019 Marc René Schädler
% E-mail: marc.r.schaedler@uni-oldenburg.de
%
% [1] Kaernbach, C. (1990). A single‐interval adjustment‐matrix (SIAM) procedure for unbiased adaptive testing. The Journal of the Acoustical Society of America, 88(6), 2645-2655. https://doi.org/10.1121/1.399985
% Contribution: David Hülsmeier

% Example config
%  target = 0.75;
%  minreversals = 14;
%  discardreversals = 4;
%  minmeasures = 25;
%  startvalue = 10;
%  steps = [4 4 2 1];
%  feedback = 1;

% Initial values
value = startvalue;
direction = [];
count = 0;

% Definition for clipping
clip_count = 0;
clip_count_to_abort_experiment = 5;
clip_value = 115; % dB ; maximum presentation level

threshold = nan;
values = [];
reversals = [];
measures = [];
presentations = [];
answers = [];
adjustments = [];
offsets = [];

adjustment_matrix = [-1 target./(1-target); 1./(1-target) 0];
minstep = min(min(abs(adjustment_matrix(abs(adjustment_matrix)>0))));
adjustment_matrix = adjustment_matrix ./ minstep;

assert(discardreversals>=0 && discardreversals<minreversals);
assert(minmeasures >= 1);

% Measure loop
while ( sum(abs(reversals))<minreversals || sum(presentations(measures==1))<minmeasures ) && clip_count<clip_count_to_abort_experiment
  count = count + 1;

  % omit clipping
  if value > clip_value
    value = clip_value;
    clip_count = clip_count + 1;
  end

  % Present random stimulus after third presentation
  if count < 4
    presentation = 1;
  else
    presentation = round(rand(1));
  end

  offset = presentationhandle(presentation, value);
  presentations(count) = presentation;
  values(count) = value;
  offsets(count) = offset;

  % Get answer
  answer = answerhandle(count, presentation, value);
  answers(count) = answer;

  %% Give feedback
  if feedback
    if answer == presentation
      printf('%3i| CORRECT!\n',count);
    else
      printf('%3i| WRONG!\n',count);
    end
  end

  % Determine adjustment
  adjustment = adjustment_matrix(2-presentation, 2-answer) .* steps(min(1+sum(abs(reversals)),end));
  adjustments(count) = adjustment;

  % Apply adjustment
  value = value + adjustment;

  % Detect reversals
  if isempty(direction) && adjustment ~= 0
    direction = adjustment;
  elseif (adjustment>0 && direction<0) || (adjustment<0 && direction>0)
    direction = adjustment;
    reversals(count) = sign(direction);
  else
    reversals(count) = 0;
  end

  % Mark measures
  if sum(abs(reversals)) > discardreversals
    measures(count) = 1;
  else
    measures(count) = 0;
  end
end

% Evaluate measurement
if sum(abs(reversals))>=minreversals && sum(measures)>=minmeasures
  reversalvalues = values(logical(abs(reversals)));
  usereversalvalues = reversalvalues(1+discardreversals:end);
  threshold = median(usereversalvalues);
end
end
