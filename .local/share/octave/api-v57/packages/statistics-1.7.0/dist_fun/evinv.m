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
## @deftypefn  {statistics} {@var{x} =} evinv (@var{p})
## @deftypefnx {statistics} {@var{x} =} evinv (@var{p}, @var{mu})
## @deftypefnx {statistics} {@var{x} =} evinv (@var{p}, @var{mu}, @var{sigma})
## @deftypefnx {statistics} {[@var{x}, @var{xlo}, @var{xup}] =} evinv (@var{p}, @var{mu}, @var{sigma}, @var{pcov})
## @deftypefnx {statistics} {[@var{x}, @var{xlo}, @var{xup}] =} evinv (@var{p}, @var{mu}, @var{sigma}, @var{pcov}, @var{alpha})
##
## Inverse of the extreme value cumulative distribution function (iCDF).
##
## For each element of @var{p}, compute the quantile (the inverse of the CDF) of
## the extreme value distribution (also known as the Gumbel or the type I
## generalized extreme value distribution) with location parameter @var{mu} and
## scale parameter @var{sigma}.  The size of @var{x} is the common size of
## @var{p}, @var{mu} and @var{sigma}.  A scalar input functions as a constant
## matrix of the same size as the other inputs.
##
## Default values are @var{mu} = 0 and @var{sigma} = 1.
##
## When called with three output arguments, i.e. @qcode{[@var{x}, @var{xlo},
## @var{xup}]}, @code{evinv} computes the confidence bounds for @var{x} when the
## input parameters @var{mu} and @var{sigma} are estimates.  In such case,
## @var{pcov}, a @math{2x2} matrix containing the covariance matrix of the
## estimated parameters, is necessary.  Optionally, @var{alpha}, which has a
## default value of 0.05, specifies the @qcode{100 * (1 - @var{alpha})} percent
## confidence bounds.  @var{xlo} and @var{xup} are arrays of the same size as
## @var{x} containing the lower and upper confidence bounds.
##
## The Gumbel distribution is used to model the distribution of the maximum (or
## the minimum) of a number of samples of various distributions.  This version
## is suitable for modeling minima.  For modeling maxima, use the alternative
## Gumbel iCDF, @code{gumbelinv}.
##
## Further information about the Gumbel distribution can be found at
## @url{https://en.wikipedia.org/wiki/Gumbel_distribution}
##
## @seealso{evcdf, evpdf, evrnd, evfit, evlike, evstat, gumbelinv}
## @end deftypefn

function [x, xlo, xup] = evinv (p, mu, sigma, pcov, alpha)

  ## Check for valid number of input arguments
  if (nargin < 1 || nargin > 5)
    error ("evinv: invalid number of input arguments.");
  endif

  ## Add defaults (if missing input arguments)
  if (nargin < 2)
    mu = 0;
  endif
  if (nargin < 3)
    sigma = 1;
  endif

  ## Check if PCOV is provided when confidence bounds are requested
  if (nargout > 2)
    if (nargin < 4)
      error ("evinv: covariance matrix is required for confidence bounds.");
    endif

    ## Check for valid covariance matrix 2x2
    if (! isequal (size (pcov), [2, 2]))
      error ("evinv: invalid size of covariance matrix.");
    endif

    ## Check for valid alpha value
    if (nargin < 5)
      alpha = 0.05;
    elseif (! isnumeric (alpha) || numel (alpha) !=1 || alpha <= 0 || alpha >= 1)
      error ("evinv: invalid value for alpha.");
    endif
  endif

  ## Check for common size of P, MU, and SIGMA
  if (! isscalar (p) || ! isscalar (mu) || ! isscalar (sigma))
    [err, p, mu, sigma] = common_size (p, mu, sigma);
    if (err > 0)
      error ("evinv: P, MU, and SIGMA must be of common size or scalars.");
    endif
  endif

  ## Check for P, MU, and SIGMA being reals
  if (iscomplex (p) || iscomplex (mu) || iscomplex (sigma))
    error ("evinv: P, MU, and SIGMA must not be complex.");
  endif

  ## Check for appropriate class
  if (isa (p, "single") || isa (mu, "single") || isa (sigma, "single"));
    is_class = "single";
  else
    is_class = "double";
  endif

  ## Compute inverse of type 1 extreme value cdf
  k = (eps <= p & p < 1);
  if (all (k(:)))
    q = log (-log (1 - p));
  else
    q = zeros (size (p), is_class);
    q(k) = log (-log (1 - p(k)));
    ## Return -Inf for p = 0 and Inf for p = 1
    q(p < eps) = -Inf;
    q(p == 1) = Inf;
    ## Return NaN for out of range values of P
    q(p < 0 | 1 < p | isnan (p)) = NaN;
  endif

  ## Return NaN for out of range values of SIGMA
  sigma(sigma <= 0) = NaN;
  x = sigma .* q + mu;

  ## Compute confidence bounds if requested.
  if (nargout >= 2)
    xvar = pcov(1,1) + 2 * pcov(1,2) * q + pcov(2,2) * q .^ 2;
    if (any (xvar < 0))
      error ("evinv: bad covariance matrix.");
    endif
    z = -norminv (alpha / 2);
    halfwidth = z * sqrt (xvar);
    xlo = x - halfwidth;
    xup = x + halfwidth;
  endif

endfunction

%!demo
%! ## Plot various iCDFs from the extreme value distribution
%! p = 0.001:0.001:0.999;
%! x1 = evinv (p, 0.5, 2);
%! x2 = evinv (p, 1.0, 2);
%! x3 = evinv (p, 1.5, 3);
%! x4 = evinv (p, 3.0, 4);
%! plot (p, x1, "-b", p, x2, "-g", p, x3, "-r", p, x4, "-c")
%! grid on
%! ylim ([-10, 10])
%! legend ({"μ = 0.5, σ = 2", "μ = 1.0, σ = 2", ...
%!          "μ = 1.5, σ = 3", "μ = 3.0, σ = 4"}, "location", "northwest")
%! title ("Extreme value iCDF")
%! xlabel ("probability")
%! ylabel ("values in x")

## Test output
%!shared p, x
%! p = [0, 0.05, 0.5 0.95];
%! x = [-Inf, -2.9702, -0.3665, 1.0972];
%!assert (evinv (p), x, 1e-4)
%!assert (evinv (p, zeros (1,4), ones (1,4)), x, 1e-4)
%!assert (evinv (p, 0, ones (1,4)), x, 1e-4)
%!assert (evinv (p, zeros (1,4), 1), x, 1e-4)
%!assert (evinv (p, [0, -Inf, NaN, Inf], 1), [-Inf, -Inf, NaN, Inf], 1e-4)
%!assert (evinv (p, 0, [Inf, NaN, -1, 0]), [-Inf, NaN, NaN, NaN], 1e-4)
%!assert (evinv ([p(1:2), NaN, p(4)], 0, 1), [x(1:2), NaN, x(4)], 1e-4)

## Test class of input preserved
%!assert (evinv ([p, NaN], 0, 1), [x, NaN], 1e-4)
%!assert (evinv (single ([p, NaN]), 0, 1), single ([x, NaN]), 1e-4)
%!assert (evinv ([p, NaN], single (0), 1), single ([x, NaN]), 1e-4)
%!assert (evinv ([p, NaN], 0, single (1)), single ([x, NaN]), 1e-4)

## Test input validation
%!error<evinv: invalid number of input arguments.> evinv ()
%!error evinv (1,2,3,4,5,6)
%!error<evinv: P, MU, and SIGMA must be of common size or scalars.> ...
%! evinv (ones (3), ones (2), ones (2))
%!error<evinv: invalid size of covariance matrix.> ...
%! [p, plo, pup] = evinv (2, 3, 4, [1, 2])
%!error<evinv: covariance matrix is required for confidence bounds.> ...
%! [p, plo, pup] = evinv (1, 2, 3)
%!error<evinv: invalid value for alpha.> [p, plo, pup] = ...
%! evinv (1, 2, 3, [1, 0; 0, 1], 0)
%!error<evinv: invalid value for alpha.> [p, plo, pup] = ...
%! evinv (1, 2, 3, [1, 0; 0, 1], 1.22)
%!error<evinv: P, MU, and SIGMA must not be complex.> evinv (i, 2, 2)
%!error<evinv: P, MU, and SIGMA must not be complex.> evinv (2, i, 2)
%!error<evinv: P, MU, and SIGMA must not be complex.> evinv (2, 2, i)
%!error<evinv: bad covariance matrix.> ...
%! [p, plo, pup] = evinv (1, 2, 3, [-1, -10; -Inf, -Inf], 0.04)
