(function(global) {
  'use strict';

  function InterestCalculatorModel(presentValue, yearsOfGrowth, annualPayment) {

    var DEFAULT_INTEREST_RATE = 5;

    this.presentValue = presentValue;
    this.yearsOfGrowth = yearsOfGrowth;
    this.annualPayment = annualPayment || 0;
    this.interestRate =  DEFAULT_INTEREST_RATE;
  }

  InterestCalculatorModel.prototype.growthValue = function () {

    function _recur(presentValue, yearsOfGrowth, annualPayment, interestRate) {
      var endOfYearAmount =  (presentValue + annualPayment) * (1 + interestRate/100);
      yearsOfGrowth--;

      if (yearsOfGrowth < 1) {
        return Math.round(endOfYearAmount);
      } else {
        return _recur(endOfYearAmount, yearsOfGrowth, annualPayment, interestRate);
      }
    }

    return _recur(this.presentValue, this.yearsOfGrowth, this.annualPayment, this.interestRate);
  };

  InterestCalculatorModel.prototype.interest = function () {
    return this.growthValue() - this.presentValue;
  };

  global.InterestCalculatorModel = InterestCalculatorModel;

})(this);
