function out = sigmoid(L, L_50, s_50, p)
out = 1./ ( 1 + exp(4.*s_50.*(L_50-L)) );
out = out * (p(2)-p(1))+p(1);
end