## Copyright (C) 2022-2023 Andreas Bertsatos <abertsatos@biol.uoa.gr>
##
## This file is part of the statistics package for GNU Octave.
##
## This program is free software; you can redistribute it and/or modify it under
## the terms of the GNU General Public License as published by the Free Software
## Foundation; either version 3 of the License, or (at your option) any later
## version.
##
## This program is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
## FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
## details.
##
## You should have received a copy of the GNU General Public License along with
## this program; if not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn  {statistics} {@var{y} =} ncx2pdf (@var{x}, @var{df}, @var{lambda})
##
## Noncentral chi-squared probability distribution function (PDF).
##
## For each element of @var{x}, compute the probability density function (PDF)
## of the noncentral chi-squared distribution with @var{df} degrees of freedom
## and noncentrality parameter @var{lambda}.  The size of @var{y} is the common
## size of @var{x}, @var{df}, and @var{lambda}.  A scalar input functions as a
## constant matrix of the same size as the other inputs.
##
## Further information about the noncentral chi-squared distribution can be
## found at @url{https://en.wikipedia.org/wiki/Noncentral_chi-squared_distribution}
##
## @seealso{ncx2cdf, ncx2inv, ncx2rnd, ncx2stat, chi2pdf}
## @end deftypefn

function y = ncx2pdf (x, df, lambda)

  ## Check for valid number of input arguments
  if (nargin <  3)
    error ("ncx2pdf: function called with too few input arguments.");
  endif

  ## Check for common size of X, DF, and LAMBDA
  [err, x, df, lambda] = common_size (x, df, lambda);
  if (err > 0)
    error ("ncx2pdf: X, DF, and LAMBDA must be of common size or scalars.");
  endif

  ## Check for X, DF, and LAMBDA being reals
  if (iscomplex (x) || iscomplex (df) || iscomplex (lambda))
    error ("ncx2pdf: X, DF, and LAMBDA must not be complex.");
  endif

  ## Check for class type
  if (isa (x, "single") || isa (df, "single") || isa (lambda, "single"))
    y = zeros (size (x), "single");
  else
    y = zeros (size (x));
  endif

  ## Find NaNs in input arguments (if any) and propagate them to p
  is_nan = isnan (x) | isnan (df) | isnan (lambda);
  y(is_nan) = NaN;

  ## Make input arguments column vectors and half DF
  x = x(:);
  df = df(:);
  df = df / 2;
  lambda = lambda(:);

  ## Handle special cases
  k1 = x == 0 & df == 1;
  y(k1) = 0.5 * exp (-0.5 * lambda(k1));
  k2 = x == 0 & df < 1;
  y(k2) = Inf;
  y(lambda < 0) = NaN;
  y(df < 0) = NaN;
  k3 = lambda == 0 & df > 0;
  y(k3) = gampdf (x(k3), df(k3), 2);

  ## Handle normal cases
  td = find(x>0 & x<Inf & lambda>0 & df>=0);
  ## Return if finished all normal cases
  if (isempty (td))
    return;
  endif

  ## Reset input variables to remaining cases
  x = x(td);
  lambda = lambda(td);
  df = df(td) - 1;
  x_sqrt = sqrt (x);
  d_sqrt = sqrt (lambda);

  ## Upper Limit on density
  small_DF = df <= -0.5;
  large_DF = ! small_DF;
  ul = zeros (size (x));
  ul(small_DF) = -0.5 * (lambda(small_DF) + x(small_DF)) + ...
                  0.5 * x_sqrt(small_DF) .* d_sqrt (small_DF) ./ ...
                  (df(small_DF) + 1) + df(small_DF) .* ...
                  (log (x(small_DF)) - log (2)) - log (2) - ...
                  gammaln (df(small_DF) + 1);
  ul(large_DF) = -0.5 * (d_sqrt(large_DF) - x_sqrt(large_DF)) .^ 2 + ...
                  df(large_DF) .* (log (x(large_DF)) - log (2)) - log (2) - ...
                  gammaln (df(large_DF) + 1) + (df(large_DF) + 0.5) .* ...
                  log ((df(large_DF) + 0.5) ./ (x_sqrt(large_DF) .* ...
                  d_sqrt(large_DF) + df(large_DF) + 0.5));
  ULunderflow = ul < log (realmin);
  y(td(ULunderflow)) = 0;
  td(ULunderflow) = [];
  ## Return if finished all normal cases
  if (isempty (td))
    return;
  endif
  x(ULunderflow) = [];
  lambda(ULunderflow) = [];
  df(ULunderflow) = [];
  x_sqrt(ULunderflow) = [];
  d_sqrt(ULunderflow) = [];

  ## Try the scaled Bess function
  scaleB = besseli (df, d_sqrt .* x_sqrt, 1);
  use_SB = scaleB > 0 & scaleB < Inf;
  y(td(use_SB)) = exp (-log (2) -0.5 * (x_sqrt(use_SB) - ...
                  d_sqrt(use_SB)) .^ 2 + df(use_SB) .* ...
                  log (x_sqrt(use_SB) ./ d_sqrt(use_SB))) .* scaleB(use_SB);
  td(use_SB) = [];
  ## Return if finished all normal cases
  if (isempty (td))
    return;
  endif
  x(use_SB) = [];
  lambda(use_SB) = [];
  df(use_SB) = [];
  x_sqrt(use_SB) = [];
  d_sqrt(use_SB) = [];

  ## Try the Bess function
  Bess = besseli (df, d_sqrt .* x_sqrt);
  useB = Bess > 0 & Bess < Inf;
  y(td(useB)) = exp (-log (2) - 0.5 * (x(useB) + lambda(useB)) + ...
                df(useB) .* log (x_sqrt(useB) ./ d_sqrt(useB))) .* Bess(useB);
  td(useB) = [];
  ## Return if finished all normal cases
  if isempty(td)
    return;
  endif
  x(useB) = [];
  lambda(useB) = [];
  df(useB) = [];

  ## If neither Bess function works, use recursion. When non-centrality
  ## parameter is very large, the initial values of the Poisson numbers used
  ## in the approximation are very small, smaller than epsilon. This would
  ## cause premature convergence. To avoid that, we start from the peak of the
  ## Poisson numbers, and go in both directions.
  lnsr2pi = 0.9189385332046727; % log(sqrt(2*pi))
  dx = lambda .* x / 4;
  K = max (0, floor (0.5 * (sqrt (df .^ 2 + 4 * dx) - df)));
  lntK = zeros(size(K));
  K0 = K == 0;
  lntK(K0) = -lnsr2pi -0.5 * (lambda(K0) + log(df(K0))) - ...
              StirlingError (df(K0)) - BinoPoisson (df(K0), x(K0) / 2);
  K0 = ! K0;
  lntK(K0) = -2 * lnsr2pi - 0.5 * (log (K(K0)) + log (df(K0) + K(K0))) - ...
              StirlingError (K(K0)) - StirlingError (df(K0) + K(K0)) - ...
              BinoPoisson (K(K0), lambda(K0) / 2) - ...
              BinoPoisson (df(K0) + K(K0), x(K0) / 2);
  sumK = ones (size (K));
  keep = K>0;
  term = ones (size (K));
  k = K;
  while (any (keep))
    term(keep) = term(keep) .* (df(keep) + k(keep)) .* k(keep) ./ dx(keep);
    sumK(keep) = sumK(keep) + term(keep);
    keep = keep & k > 0 & term > eps (sumK);
    k = k - 1;
  endwhile
  keep = true (size (K));
  term = ones (size (K));
  k = K + 1;
  while (any (keep))
    term(keep) = term(keep) ./ (df(keep) + k(keep)) ./ k(keep) .* dx(keep);
    sumK(keep) = sumK(keep) + term(keep);
    keep = keep & term > eps (sumK);
    k = k + 1;
  end
  y(td) = 0.5 * exp (lntK + log (sumK));

endfunction

## Error of Stirling-De Moivre approximation to n factorial.
function lambda = StirlingError (n)
  is_class = class (n);
  lambda = zeros (size (n), is_class);
  nn = n .* n;
  ## Define S0=1/12 S1=1/360 S2=1/1260 S3=1/1680 S4=1/1188
  S0 = 8.333333333333333e-02;
  S1 = 2.777777777777778e-03;
  S2 = 7.936507936507937e-04;
  S3 = 5.952380952380952e-04;
  S4 = 8.417508417508418e-04;
  ## Define lambda(n) for n<0:0.5:15
  sfe=[                    0;       1.534264097200273e-01;...
       8.106146679532726e-02;       5.481412105191765e-02;...
       4.134069595540929e-02;       3.316287351993629e-02;...
       2.767792568499834e-02;       2.374616365629750e-02;...
       2.079067210376509e-02;       1.848845053267319e-02;...
       1.664469118982119e-02;       1.513497322191738e-02;...
       1.387612882307075e-02;       1.281046524292023e-02;...
       1.189670994589177e-02;       1.110455975820868e-02;...
       1.041126526197210e-02;       9.799416126158803e-03;...
       9.255462182712733e-03;       8.768700134139385e-03;...
       8.330563433362871e-03;       7.934114564314021e-03;...
       7.573675487951841e-03;       7.244554301320383e-03;...
       6.942840107209530e-03;       6.665247032707682e-03;...
       6.408994188004207e-03;       6.171712263039458e-03;...
       5.951370112758848e-03;       5.746216513010116e-03;...
       5.554733551962801e-03];
  k = find (n <= 15);
  if (any (k))
    n1 = n(k);
    n2 = 2 * n1;
    if (all (n2 == round (n2)))
        lambda(k) = sfe(n2+1);
    else
        lnsr2pi = 0.9189385332046728;
        lambda(k) = gammaln(n1+1)-(n1+0.5).*log(n1)+n1-lnsr2pi;
    endif
  endif
  k = find (n > 15 & n <= 35);
  if (any (k))
    lambda(k) = (S0 - (S1 - (S2 - (S3 - S4 ./ nn(k)) ./ nn(k)) ./ ...
                                             nn(k)) ./ nn(k)) ./ n(k);
  endif
  k = find (n > 35 & n <= 80);
  if (any (k))
    lambda(k) = (S0 - (S1 - (S2 - S3 ./ nn(k)) ./ nn(k)) ./ nn(k)) ./ n(k);
  endif
  k = find(n > 80 & n <= 500);
  if (any (k))
    lambda(k) = (S0 - (S1 - S2 ./ nn(k)) ./ nn(k)) ./ n(k);
  endif
  k = find(n > 500);
  if (any (k))
    lambda(k) = (S0 - S1 ./ nn(k)) ./ n(k);
  endif
endfunction

## Deviance term for binomial and Poisson probability calculation.
function BP = BinoPoisson (x, np)
  if (isa (x,'single') || isa (np,'single'))
    BP = zeros (size (x), "single");
  else
    BP = zeros (size (x));
  endif
  k = abs (x - np) < 0.1 * (x + np);
  if any(k(:))
    s = (x(k) - np(k)) .* (x(k) - np(k)) ./ (x(k) + np(k));
    v = (x(k) - np(k)) ./ (x(k) + np(k));
    ej = 2 .* x(k) .* v;
    is_class = class (s);
    s1 = zeros (size (s), is_class);
    ok = true (size (s));
    j = 0;
    while any(ok(:))
      ej(ok) = ej(ok) .* v(ok) .* v(ok);
      j = j + 1;
      s1(ok) = s(ok) + ej(ok) ./ (2 * j + 1);
      ok = ok & s1 != s;
      s(ok) = s1(ok);
    endwhile
    BP(k) = s;
  endif
  k = ! k;
  if (any (k(:)))
    BP(k) = x(k) .* log (x(k) ./ np(k)) + np(k) - x(k);
  endif
endfunction

%!demo
%! ## Plot various PDFs from the noncentral chi-squared distribution
%! x = 0:0.1:10;
%! y1 = ncx2pdf (x, 2, 1);
%! y2 = ncx2pdf (x, 2, 2);
%! y3 = ncx2pdf (x, 2, 3);
%! y4 = ncx2pdf (x, 4, 1);
%! y5 = ncx2pdf (x, 4, 2);
%! y6 = ncx2pdf (x, 4, 3);
%! plot (x, y1, "-r", x, y2, "-g", x, y3, "-k", ...
%!       x, y4, "-m", x, y5, "-c", x, y6, "-y")
%! grid on
%! xlim ([0, 10])
%! ylim ([0, 0.32])
%! legend ({"df = 2, λ = 1", "df = 2, λ = 2", ...
%!          "df = 2, λ = 3", "df = 4, λ = 1", ...
%!          "df = 4, λ = 2", "df = 4, λ = 3"}, "location", "northeast")
%! title ("Noncentral chi-squared PDF")
%! xlabel ("values in x")
%! ylabel ("density")

%!demo
%! ## Compare the noncentral chi-squared PDF with LAMBDA = 2 to the
%! ## chi-squared PDF with the same number of degrees of freedom (4).
%!
%! x = 0:0.1:10;
%! y1 = ncx2pdf (x, 4, 2);
%! y2 = chi2pdf (x, 4);
%! plot (x, y1, "-", x, y2, "-");
%! grid on
%! xlim ([0, 10])
%! ylim ([0, 0.32])
%! legend ({"Noncentral T(10,1)", "T(10)"}, "location", "northwest")
%! title ("Noncentral chi-squared vs chi-squared PDFs")
%! xlabel ("values in x")
%! ylabel ("density")

## Test output
%!shared x1, df, d1
%! x1 = [-Inf, 2, NaN, 4, Inf];
%! df = [2, 0, -1, 1, 4];
%! d1 = [1, NaN, 3, -1, 2];
%!assert (ncx2pdf (x1, df, d1), [0, NaN, NaN, NaN, 0]);
%!assert (ncx2pdf (x1, df, 1), [0, 0.07093996461786045, NaN, ...
%!                              0.06160064323277038, 0], 1e-14);
%!assert (ncx2pdf (x1, df, 3), [0, 0.1208364909271113, NaN, ...
%!                              0.09631299762429098, 0], 1e-14);
%!assert (ncx2pdf (x1, df, 2), [0, 0.1076346446244688, NaN, ...
%!                              0.08430464047296625, 0], 1e-14);
%!assert (ncx2pdf (x1, 2, d1), [0, NaN, NaN, NaN, 0]);
%!assert (ncx2pdf (2, df, d1), [0.1747201674611283, NaN, NaN, ...
%!                              NaN, 0.1076346446244688], 1e-14);
%!assert (ncx2pdf (4, df, d1), [0.09355987820265799, NaN, NaN, ...
%!                              NaN, 0.1192317192431485], 1e-14);

## Test input validation
%!error<ncx2pdf: function called with too few input arguments.> ncx2pdf ()
%!error<ncx2pdf: function called with too few input arguments.> ncx2pdf (1)
%!error<ncx2pdf: function called with too few input arguments.> ncx2pdf (1, 2)
%!error<ncx2pdf: X, DF, and LAMBDA must be of common size or scalars.> ...
%! ncx2pdf (ones (3), ones (2), ones (2))
%!error<ncx2pdf: X, DF, and LAMBDA must be of common size or scalars.> ...
%! ncx2pdf (ones (2), ones (3), ones (2))
%!error<ncx2pdf: X, DF, and LAMBDA must be of common size or scalars.> ...
%! ncx2pdf (ones (2), ones (2), ones (3))
%!error<ncx2pdf: X, DF, and LAMBDA must not be complex.> ncx2pdf (i, 2, 2)
%!error<ncx2pdf: X, DF, and LAMBDA must not be complex.> ncx2pdf (2, i, 2)
%!error<ncx2pdf: X, DF, and LAMBDA must not be complex.> ncx2pdf (2, 2, i)
