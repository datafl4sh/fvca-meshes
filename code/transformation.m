function [x_f] = transformation (x_i, y, theta)
% On applique une rotation d'angle theta

if (x_i<=1/2)
    x_f = x_i*((tan(theta)+1)-2*tan(theta)*y);
else
    x_f = 1-((1-x_i)*((tan(theta)+1)-2*tan(theta)*(1-y)));
end

end