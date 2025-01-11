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
## @deftypefn  {statistics} {@var{nlogL} =} gumbellike (@var{params}, @var{x})
## @deftypefnx {statistics} {[@var{nlogL}, @var{avar}] =} gumbellike (@var{params}, @var{x})
## @deftypefnx {statistics} {[@dots{}] =} gumbellike (@var{params}, @var{x}, @var{censor})
## @deftypefnx {statistics} {[@dots{}] =} gumbellike (@var{params}, @var{x}, @var{censor}, @var{freq})
##
## Negative log-likelihood for the extreme value distribution.
##
## @code{@var{nlogL} = gumbellike (@var{params}, @var{x})} returns the negative
## log likelihood of the data in @var{x} corresponding to the Gumbel
## distribution (also known as the extreme value or the type I generalized
## extreme value distribution) with (1) location parameter @var{mu} and (2)
## scale parameter @var{beta} given in the two-element vector @var{params}.
##
## @code{[@var{nlogL}, @var{acov}] = gumbellike (@var{params}, @var{x})} also
## returns the inverse of Fisher's information matrix, @var{acov}.  If the input
## parameter values in @var{params} are the maximum likelihood estimates, the
## diagonal elements of @var{acov} are their asymptotic variances.
##
## @code{[@dots{}] = gumbellike (@var{params}, @var{x}, @var{censor})} accepts a
## boolean vector, @var{censor}, of the same size as @var{x} with @qcode{1}s for
## observations that are right-censored and @qcode{0}s for observations that are
## observed exactly.  By default, or if left empty,
## @qcode{@var{censor} = zeros (size (@var{x}))}.
##
## @code{[@dots{}] = gumbellike (@var{params}, @var{x}, @var{censor}, @var{freq})}
## accepts a frequency vector, @var{freq}, of the same size as @var{x}.
## @var{freq} typically contains integer frequencies for the corresponding
## elements in @var{x}, but it can contain any non-integer non-negative values.
## By default, or if left empty, @qcode{@var{freq} = ones (size (@var{x}))}.
##
## The Gumbel distribution is used to model the distribution of the maximum (or
## the minimum) of a number of samples of various distributions.  This version
## is suitable for modeling maxima.  For modeling minima, use the alternative
## extreme value likelihood function, @code{evlike}.
##
## Further information about the Gumbel distribution can be found at
## @url{https://en.wikipedia.org/wiki/Gumbel_distribution}
##
## @seealso{gumbelcdf, gumbelinv, gumbelpdf, gumbelrnd, gumbelfit, gumbelstat,
## evlike}
## @end deftypefn

function [nlogL, avar] = gumbellike (params, x, censor, freq)

  ## Check input arguments and add defaults
  if (nargin < 2)
    error ("gumbellike: too few input arguments.");
  endif
  if (numel (params) != 2)
    error ("gumbellike: wrong parameters length.");
  endif
  if (! isvector (x))
    error ("gumbellike: X must be a vector.");
  endif
  if (nargin < 3 || isempty (censor))
    censor = zeros (size (x));
  elseif (! isequal (size (x), size (censor)))
    error ("gumbellike: X and CENSOR vectors mismatch.");
  endif
  if (nargin < 4 || isempty (freq))
    freq = ones (size (x));
  elseif (isequal (size (x), size (freq)))
    nulls = find (freq == 0);
    if (numel (nulls) > 0)
      x(nulls) = [];
      censor(nulls) = [];
      freq(nulls) = [];
    endif
  else
    error ("gumbellike: X and FREQ vectors mismatch.");
  endif

  ## Get mu and sigma values
  mu = params(1);
  sigma = params(2);

  ## sigma must be positive, otherwise make it NaN
  if (sigma <= 0)
    sigma = NaN;
  endif

  ## Compute the individual log-likelihood terms.  Force a log(0)==-Inf for
  ## x from extreme right tail, instead of getting exp(Inf-Inf)==NaN.
  z = (x - mu) ./ sigma;
  expz = exp (z);
  L = (z - log (sigma)) .* (1 - censor) - expz;
  L(z == Inf) = -Inf;

  ## Neg-log-like is the sum of the individual contributions
  nlogL = -sum (freq .* L);

  ## Compute the negative hessian at the parameter values.
  ## Invert to get the observed information matrix.
  if (nargout == 2)
    unc = (1-censor);
    nH11 = sum(freq .* expz);
    nH12 = sum(freq .* ((z + 1) .* expz - unc));
    nH22 = sum(freq .* (z .* (z+2) .* expz - ((2 .* z + 1) .* unc)));
    avar =  (sigma .^ 2) * ...
            [nH22 -nH12; -nH12 nH11] / (nH11 * nH22 - nH12 * nH12);
  endif
endfunction

## Test output
%!test
%! x = 1:50;
%! [nlogL, avar] = gumbellike ([2.3, 1.2], x);
%! avar_out = [-1.2778e-13, 3.1859e-15; 3.1859e-15, -7.9430e-17];
%! assert (nlogL, 3.242264755689906e+17, 1e-14);
%! assert (avar, avar_out, 1e-3);
%!test
%! x = 1:50;
%! [nlogL, avar] = gumbellike ([2.3, 1.2], x * 0.5);
%! avar_out = [-7.6094e-05, 3.9819e-06; 3.9819e-06, -2.0836e-07];
%! assert (nlogL, 481898704.0472211, 1e-6);
%! assert (avar, avar_out, 1e-3);
%!test
%! x = 1:50;
%! [nlogL, avar] = gumbellike ([21, 15], x);
%! avar_out = [11.73913876598908, -5.9546128523121216; ...
%!             -5.954612852312121, 3.708060045170236];
%! assert (nlogL, 223.7612479380652, 1e-13);
%! assert (avar, avar_out, 1e-14);

## Test input validation
%!error<gumbellike: too few input arguments.> gumbellike ([12, 15]);
%!error<gumbellike: wrong parameters length.> gumbellike ([12, 15, 3], [1:50]);
%!error<gumbellike: X must be a vector.> gumbellike ([12, 3], ones (10, 2));
%!error<gumbellike: X and CENSOR> gumbellike ([12, 15], [1:50], [1, 2, 3]);
%!error<gumbellike: X and FREQ> gumbellike ([12, 15], [1:50], [], [1, 2, 3]);
