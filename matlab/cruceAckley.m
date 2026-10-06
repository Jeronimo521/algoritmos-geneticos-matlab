function [h1,h2] = cruceAckley(p1,p2)
alfa=rand();
h1=alfa*p1+(1-alfa)*p2;
h2=alfa*p2+(1-alfa)*p1;
end
