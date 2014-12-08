(function(global) {
  'use strict';

  function decimalYearToString(decimal) {

    if (decimal < 0 ) {
      throw new Error('Argument can not be a negative number');
    }

    if (typeof decimal === 'string' ) {
      throw new Error('Argument can not be string');
    }

    var years = Math.floor(decimal),
        months = Math.floor((decimal % 1) * 12),
        yearString,
        monthString,
        yearMonthSeperator = '';

    if (years === 0) {
      yearString = '';
    } else if (years === 1) {
      yearString = '1 year';
    } else {
      yearString = years + ' years';
    }

    if (months === 0) {
      monthString = '';
    } else if (months === 1){
      monthString = '1 month';
    } else {
      monthString = months + ' months';
    }

    if (yearString && months) {
      yearMonthSeperator = ' ';
    }

    return yearString + yearMonthSeperator + monthString;
  }

  global.decimalYearToString = decimalYearToString;

})(this);
