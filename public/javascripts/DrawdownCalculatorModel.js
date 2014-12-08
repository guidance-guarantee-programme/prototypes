(function(global) {
  'use strict';

  function DrawdownCalculatorModel(presentValue, annualWithdrawl) {

    var DEFAULT_INTEREST_RATE = 5;

    this.presentValue = presentValue;
    this.annualWithdrawl = annualWithdrawl || 0;
    this.interestRate =  DEFAULT_INTEREST_RATE;
  }

  DrawdownCalculatorModel.prototype.howLongMoneyWillLast = function () {
    var years = 0;

    function _recur(presentValue, annualWithdrawl, interestRate) {
      var endOfYearAmount =  (presentValue - annualWithdrawl) * (1 + interestRate/100);
      years++;

      if (endOfYearAmount < annualWithdrawl) {
        return years + Math.round((endOfYearAmount/annualWithdrawl) * 10)/10;
      } else {
        return _recur(endOfYearAmount, annualWithdrawl, interestRate);
      }
    }

    return _recur(this.presentValue, this.annualWithdrawl, this.interestRate);
  };

  DrawdownCalculatorModel.prototype.decimalToString = function () {
    return '1 month';
  };

  global.DrawdownCalculatorModel = DrawdownCalculatorModel;

})(this);
