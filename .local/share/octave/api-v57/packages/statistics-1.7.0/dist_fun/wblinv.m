## Copyright (C) 2012 Rik Wehbring
## Copyright (C) 1995-2016 Kurt Hornik
## Copyright (C) 2023 Andreas Bertsatos <abertsatos@biol.uoa.gr>
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
## @deftypefn  {statistics} {@var{x} =} wblinv (@var{p})
## @deftypefnx {statistics} {@var{x} =} wblinv (@var{p}, @var{lambda})
## @deftypefnx {statistics} {@var{x} =} wblinv (@var{p}, @var{lambda}, @var{k})
##
## Inverse of the Weibull cumulative distribution function (iCDF).
##
## For each element of @var{p}, compute the quantile (the inverse of the CDF)
## of the Weibull distribution with scale parameter @var{lambda} and shape
## parameter @var{k}.  The size of @var{x} is the common size of @var{p},
## @var{lambda}, and @var{k}.  A scalar input functions as a constant matrix of
## the same size as the other inputs.
##
## Default values are @var{lambda} = 1, @var{k} = 1.
##
## Further information about the Weibull distribution can be found at
## @url{https://en.wikipedia.org/wiki/Weibull_distribution}
##
## @seealso{wblcdf, wblpdf, wblrnd, wblstat, wblplot}
## @end deftypefn

function x = wblinv (p, varargin)

  ## Check for valid number of input arguments
  if (nargin < 1 || nargin > 3)
    error ("wblinv: invalid number of input arguments.");
  endif

  ## Get extra arguments (if they exist) or add defaults
  if (numel (varargin) > 0)
    lambda = varargin{1};
  else
    lambda = 1;
  endif
  if (numel (varargin) > 1)
    k = varargin{2};
  else
    k = 1;
  endif

  ## Check for common size of P, LAMBDA, and K
  if (! isscalar (p) || ! isscalar (lambda) || ! isscalar (k))
    [retval, p, lambda, k] = common_size (p, lambda, k);
    if (retval > 0)
      error ("wblinv: P, LAMBDA, and K must be of common size or scalars.");
    endif
  endif

  ## Check for P, LAMBDA, and K being reals
  if (iscomplex (p) || iscomplex (lambda) || iscomplex (k))
    error ("wblinv: P, LAMBDA, and K must not be complex.");
  endif

  ## Check for class type
  if (isa (p, "single") || isa (lambda, "single") || isa (k, "single"))
    x = NaN (size (p), "single");
  else
    x = NaN (size (p));
  endif

  ok = (lambda > 0) & (lambda < Inf) & (k > 0) & (k < Inf);

  pk = (p == 0) & ok;
  x(pk) = 0;

  pk = (p == 1) & ok;
  x(pk) = Inf;

  pk = (p > 0) & (p < 1) & ok;
  if (isscalar (lambda) && isscalar (k))
    x(pk) = lambda * (- log (1 - p(pk))) .^ (1 / k);
  else
    x(pk) = lambda(pk) .* (- log (1 - p(pk))) .^ (1 ./ k(pk));
  endif

endfunction

%!demo
%! ## Plot various iCDFs from the Weibull distribution
%! p = 0.001:0.001:0.999;
%! x1 = wblinv (p, 1, 0.5);
%! x2 = wblinv (p, 1, 1);
%! x3 = wblinv (p, 1, 1.5);
%! x4 = wblinv (p, 1, 5);
%! plot (p, x1, "-b", p, x2, "-r", p, x3, "-m", p, x4, "-g")
%! ylim ([0, 2.5])
%! grid on
%! legend ({"λ = 1, k = 0.5", "λ = 1, k = 1",  ...
%!          "λ = 1, k = 1.5", "λ = 1, k = 5"}, "location", "northwest")
%! title ("Weibull iCDF")
%! xlabel ("probability")
%! ylabel ("x")

## Test output
%!shared p
%! p = [-1 0 0.63212055882855778 1 2];
%!assert (wblinv (p, ones (1,5), ones (1,5)), [NaN 0 1 Inf NaN], eps)
%!assert (wblinv (p, 1, ones (1,5)), [NaN 0 1 Inf NaN], eps)
%!assert (wblinv (p, ones (1,5), 1), [NaN 0 1 Inf NaN], eps)
%!assert (wblinv (p, [1 -1 NaN Inf 1], 1), [NaN NaN NaN NaN NaN])
%!assert (wblinv (p, 1, [1 -1 NaN Inf 1]), [NaN NaN NaN NaN NaN])
%!assert (wblinv ([p(1:2) NaN p(4:5)], 1, 1), [NaN 0 NaN Inf NaN])

## Test class of input preserved
%!assert (wblinv ([p, NaN], 1, 1), [NaN 0 1 Inf NaN NaN], eps)
%!assert (wblinv (single ([p, NaN]), 1, 1), single ([NaN 0 1 Inf NaN NaN]), eps ("single"))
%!assert (wblinv ([p, NaN], single (1), 1), single ([NaN 0 1 Inf NaN NaN]), eps ("single"))
%!assert (wblinv ([p, NaN], 1, single (1)), single ([NaN 0 1 Inf NaN NaN]), eps ("single"))

## Test input validation
%!error<wblinv: invalid number of input arguments.> wblinv ()
%!error<wblinv: invalid number of input arguments.> wblinv (1,2,3,4)
%!error<wblinv: P, LAMBDA, and K must be of common size or scalars.> ...
%! wblinv (ones (3), ones (2), ones (2))
%!error<wblinv: P, LAMBDA, and K must be of common size or scalars.> ...
%! wblinv (ones (2), ones (3), ones (2))
%!error<wblinv: P, LAMBDA, and K must be of common size or scalars.> ...
%! wblinv (ones (2), ones (2), ones (3))
%!error<wblinv: P, LAMBDA, and K must not be complex.> wblinv (i, 2, 2)
%!error<wblinv: P, LAMBDA, and K must not be complex.> wblinv (2, i, 2)
%!error<wblinv: P, LAMBDA, and K must not be complex.> wblinv (2, 2, i)
