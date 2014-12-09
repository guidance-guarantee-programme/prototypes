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
    var pensionPot =  this.presentValue,
        yearsOfGrowth = this.yearsOfGrowth;

    while (yearsOfGrowth > 0) {
      pensionPot = (pensionPot + this.annualPayment) * (1 + this.interestRate/100);
      yearsOfGrowth--;
    }

    return Math.round(pensionPot);
  };

  InterestCalculatorModel.prototype.interest = function () {
    return this.growthValue() - this.presentValue;
  };

  global.InterestCalculatorModel = InterestCalculatorModel;

})(this);
