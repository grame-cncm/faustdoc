
// cross 10 signals: 
// input 0 -> output 10, 
// input 1 -> output 9, 
// ..., 
// input 9 -> output 0

N = 10;
r = route(N, N, par(i, N, (i+1,N-i)));

process = r;

