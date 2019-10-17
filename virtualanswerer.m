function answer = virtualanswerer(count, presentation, value, L_50, s_50, p)
persistent cache;
if nargin > 3
  cache.L_50 = L_50;
  cache.s_50 = s_50;
  cache.p = p;
else
  L_50 = cache.L_50;
  s_50 = cache.s_50;
  p = cache.p;
end

if isempty(presentation)
  answer = '';
  return
end

answer = presentation;
if rand(1) > sigmoid(value, L_50, s_50, p)
  answer = ~presentation;
end
end