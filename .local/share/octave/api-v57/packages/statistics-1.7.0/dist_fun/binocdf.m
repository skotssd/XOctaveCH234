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
## @deftypefn  {statistics} {@var{p} =} binocdf (@var{x}, @var{n}, @var{ps})
## @deftypefnx {statistics} {@var{p} =} binocdf (@var{x}, @var{n}, @var{ps}, @qcode{"upper"})
##
## Binomial cumulative distribution function (CDF).
##
## For each element of @var{x}, compute the cumulative distribution function
## (CDF) of the binomial distribution with parameters @var{n} and @var{ps},
## where @var{n} is the number of trials and @var{ps} is the probability of
## success.  The size of @var{p} is the common size of @var{x}, @var{n}, and
## @var{ps}.  A scalar input functions as a constant matrix of the same size as
## the other inputs.
##
## @code{@var{p} = binocdf (@var{x}, @var{n}, @var{ps}, "upper")} computes the
## upper tail probability of the binomial distribution with parameters
## @var{n} and @var{ps}, at the values in @var{x}.
##
## Further information about the binomial distribution can be found at
## @url{https://en.wikipedia.org/wiki/Binomial_distribution}
##
## @seealso{binoinv, binopdf, binornd, binofit, binolike, binostat, binotest}
## @end deftypefn

function p = binocdf (x, n, ps, uflag)

  ## Check for valid number of input arguments
  if (nargin < 3)
    error ("binocdf: function called with too few input arguments.");
  endif

  ## Check for valid "upper" flag
  if (nargin == 4)
    if (strcmp (uflag, "upper"))
       uflag = true;
    else
       error ("binocdf: invalid argument for upper tail.");
    endif
  else
     uflag = false;
  endif

  ## Check for common size of X, N, and PS
  if (! isscalar (x) || ! isscalar (n) || ! isscalar (ps))
    [retval, x, n, ps] = common_size (x, n, ps);
    if (retval > 0)
      error ("binocdf: X, N, and PS must be of common size or scalars.");
    endif
  endif

  ## Check for X, N, and PS being reals
  if (iscomplex (x) || iscomplex (n) || iscomplex (ps))
    error ("binocdf: X, N, and PS must not be complex.");
  endif

  ## Check for class type
  if (isa (x, "single") || isa (n, "single") || isa (ps, "single"));
    p = nan (size (x), "single");
  else
    p = nan (size (x));
  endif

  k = (x >= n) & (n >= 0) & (n == fix (n) & (ps >= 0) & (ps <= 1));
  p(k) = !uflag;

  k = (x < 0) & (n >= 0) & (n == fix (n) & (ps >= 0) & (ps <= 1));
  p(k) = uflag;

  k = (x >= 0) & (x < n) & (n == fix (n)) & (ps >= 0) & (ps <= 1);
  tmp = floor (x(k));
  if (! uflag)
    if (isscalar (n) && isscalar (ps))
      p(k) = betainc (1 - ps, n - tmp, tmp + 1);
    else
      p(k) = betainc (1 - ps(k), n(k) - tmp, tmp + 1);
    endif
  else
    if (isscalar (n) && isscalar (ps));
      p(k) = betainc (ps, tmp + 1, n - tmp);
    else
      p(k) = betainc (ps(k), tmp + 1, n(k) - tmp);
    endif
  endif

endfunction

%!demo
%! ## Plot various CDFs from the binomial distribution
%! x = 0:40;
%! p1 = binocdf (x, 20, 0.5);
%! p2 = binocdf (x, 20, 0.7);
%! p3 = binocdf (x, 40, 0.5);
%! plot (x, p1, "*b", x, p2, "*g", x, p3, "*r")
%! grid on
%! legend ({"n = 20, ps = 0.5", "n = 20, ps = 0.7", ...
%!          "n = 40, ps = 0.5"}, "location", "southeast")
%! title ("Binomial CDF")
%! xlabel ("values in x (number of successes)")
%! ylabel ("probability")

## Test output
%!shared x, p, p1
%! x = [-1 0 1 2 3];
%! p = [0 1/4 3/4 1 1];
%! p1 = 1 - p;
%!assert (binocdf (x, 2 * ones (1, 5), 0.5 * ones (1, 5)), p, eps)
%!assert (binocdf (x, 2, 0.5 * ones (1, 5)), p, eps)
%!assert (binocdf (x, 2 * ones (1, 5), 0.5), p, eps)
%!assert (binocdf (x, 2 * [0 -1 NaN 1.1 1], 0.5), [0 NaN NaN NaN 1])
%!assert (binocdf (x, 2, 0.5 * [0 -1 NaN 3 1]), [0 NaN NaN NaN 1])
%!assert (binocdf ([x(1:2) NaN x(4:5)], 2, 0.5), [p(1:2) NaN p(4:5)], eps)
%!assert (binocdf (99, 100, 0.1, "upper"), 1e-100, 1e-112);
%!assert (binocdf (x, 2 * ones (1, 5), 0.5*ones (1,5), "upper"), p1, eps)
%!assert (binocdf (x, 2, 0.5 * ones (1, 5), "upper"), p1, eps)
%!assert (binocdf (x, 2 * ones (1, 5), 0.5, "upper"), p1, eps)
%!assert (binocdf (x, 2 * [0 -1 NaN 1.1 1], 0.5, "upper"), [1 NaN NaN NaN 0])
%!assert (binocdf (x, 2, 0.5 * [0 -1 NaN 3 1], "upper"), [1 NaN NaN NaN 0])
%!assert (binocdf ([x(1:2) NaN x(4:5)], 2, 0.5, "upper"), [p1(1:2) NaN p1(4:5)])
%!assert (binocdf ([x, NaN], 2, 0.5), [p, NaN], eps)

## Test class of input preserved
%!assert (binocdf (single ([x, NaN]), 2, 0.5), single ([p, NaN]))
%!assert (binocdf ([x, NaN], single (2), 0.5), single ([p, NaN]))
%!assert (binocdf ([x, NaN], 2, single (0.5)), single ([p, NaN]))

## Test input validation
%!error<binocdf: function called with too few input arguments.> binocdf ()
%!error<binocdf: function called with too few input arguments.> binocdf (1)
%!error<binocdf: function called with too few input arguments.> binocdf (1, 2)
%!error<binocdf: function called with too many inputs> binocdf (1, 2, 3, 4, 5)
%!error<binocdf: invalid argument for upper tail.> binocdf (1, 2, 3, "tail")
%!error<binocdf: invalid argument for upper tail.> binocdf (1, 2, 3, 4)
%!error<binocdf: X, N, and PS must be of common size or scalars.> ...
%! binocdf (ones (3), ones (2), ones (2))
%!error<binocdf: X, N, and PS must be of common size or scalars.> ...
%! binocdf (ones (2), ones (3), ones (2))
%!error<binocdf: X, N, and PS must be of common size or scalars.> ...
%! binocdf (ones (2), ones (2), ones (3))
%!error<binocdf: X, N, and PS must not be complex.> binocdf (i, 2, 2)
%!error<binocdf: X, N, and PS must not be complex.> binocdf (2, i, 2)
%!error<binocdf: X, N, and PS must not be complex.> binocdf (2, 2, i)
