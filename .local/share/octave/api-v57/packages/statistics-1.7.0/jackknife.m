## Copyright (C) 2011 Alexander Klein <alexander.klein@math.uni-giessen.de>
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
## @deftypefn  {statistics} {@var{jackstat} =} jackknife (@var{E}, @var{x})
## @deftypefnx {statistics} {@var{jackstat} =} jackknife (@var{E}, @var{x}, @dots{})
##
## Compute jackknife estimates of a parameter taking one or more given samples
## as parameters.
##
## In particular, @var{E} is the estimator to be jackknifed as a function name,
## handle, or inline function, and @var{x} is the sample for which the estimate
## is to be taken.  The @var{i}-th entry of @var{jackstat} will contain the
## value of the estimator on the sample @var{x} with its @var{i}-th row omitted.
##
## @example
## @group
## jackstat (@var{i}) = @var{E}(@var{x}(1 : @var{i} - 1, @var{i} + 1 : length(@var{x})))
## @end group
## @end example
##
## Depending on the number of samples to be used, the estimator must have the
## appropriate form:
## @itemize
## @item
## If only one sample is used, then the estimator need not be concerned with
## cell arrays, for example jackknifing the standard deviation of a sample can
## be performed with @code{@var{jackstat} = jackknife (@@std, rand (100, 1))}.
## @item
## If, however, more than one sample is to be used, the samples must all be of
## equal size, and the estimator must address them as elements of a cell-array,
## in which they are aggregated in their order of appearance:
## @end itemize
##
## @example
## @group
## @var{jackstat} = jackknife (@@(x) std(x@{1@})/var(x@{2@}),
## rand (100, 1), randn (100, 1))
## @end group
## @end example
##
## If all goes well, a theoretical value @var{P} for the parameter is already
## known, @var{n} is the sample size,
##
## @code{@var{t} = @var{n} * @var{E}(@var{x}) - (@var{n} - 1) *
## mean(@var{jackstat})}
##
## and
##
## @code{@var{v} = sumsq(@var{n} * @var{E}(@var{x}) - (@var{n} - 1) *
## @var{jackstat} - @var{t}) / (@var{n} * (@var{n} - 1))}
##
## then
##
## @code{(@var{t}-@var{P})/sqrt(@var{v})} should follow a t-distribution with
## @var{n}-1 degrees of freedom.
##
## Jackknifing is a well known method to reduce bias.
## Further details can be found in:
## @subheading References
##
## @enumerate
## @item
## Rupert G. Miller. The jackknife - a review. Biometrika (1974), 61(1):1-15.
## doi:10.1093/biomet/61.1.1
## @item
## Rupert G. Miller. Jackknifing Variances. Ann. Math. Statist. (1968),
## Volume 39, Number 2, 567-582. doi:10.1214/aoms/1177698418
## @end enumerate
## @end deftypefn

function jackstat = jackknife (anEstimator, varargin)

	## Convert function name to handle if necessary, or throw an error.
	if (! strcmp (typeinfo (anEstimator), "function handle"))
		if (isascii (anEstimator))
			anEstimator = str2func (anEstimator);
		else
			error (strcat (["jackknife: estimators must be passed as function"], ...
                     [" names or handles."]));
		endif
	endif

	## Simple jackknifing can be done with a single vector argument, and
	## first and foremost with a function that does not care about cell-arrays.
	if (length (varargin) == 1 && isnumeric (varargin {1}))
		aSample = varargin{1};
		g = length (aSample);
		jackstat = zeros (1, g);
		for k = 1:g
			jackstat (k) = anEstimator (aSample([1:k - 1,k + 1:g]));
		endfor

	## More complicated input requires more work, however.
	else
		g = cellfun (@(x) length (x), varargin);

		if (any (g - g(1)))
			error ("jackknife: all passed data must be of equal length.");
		endif
		g = g(1);
		jackstat = zeros (1, g);

		for k = 1:g
			jackstat(k) = anEstimator (cellfun (@(x) x( [ 1 : k - 1, k + 1 : g ]), ...
                                 varargin, "UniformOutput", false));
		endfor
  endif

endfunction


%!demo
%! for k = 1:1000
%!   rand ("seed", k);  # for reproducibility
%!   x = rand (10, 1);
%!   s(k) = std (x);
%!   jackstat = jackknife (@std, x);
%!   j(k) = 10 * std (x) - 9 * mean (jackstat);
%! endfor
%! figure();
%! hist ([s', j'], 0:sqrt(1/12)/10:2*sqrt(1/12))

%!demo
%! for k = 1:1000
%!   randn ("seed", k); # for reproducibility
%!   x = randn (1, 50);
%!   rand ("seed", k);  # for reproducibility
%!   y = rand (1, 50);
%!   jackstat = jackknife (@(x) std(x{1})/std(x{2}), y, x);
%!   j(k) = 50 * std (y) / std (x) - 49 * mean (jackstat);
%!   v(k) = sumsq ((50 * std (y) / std (x) - 49 * jackstat) - j(k)) / (50 * 49);
%! endfor
%! t = (j - sqrt (1 / 12)) ./ sqrt (v);
%! figure();
%! plot (sort (tcdf (t, 49)), ...
%!       "-;Almost linear mapping indicates good fit with t-distribution.;")

## Test output
%!test
%! ##Example from Quenouille, Table 1
%! d=[0.18 4.00 1.04 0.85 2.14 1.01 3.01 2.33 1.57 2.19];
%! jackstat = jackknife ( @(x) 1/mean(x), d );
%! assert ( 10 / mean(d) - 9 * mean(jackstat), 0.5240, 1e-5 );
