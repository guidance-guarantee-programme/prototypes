(function(global) {
  'use strict';

  function DrawdownCalculatorModel(presentValue, annualWithdrawl) {

    var DEFAULT_INTEREST_RATE = 5;

    this.presentValue = presentValue;
    this.annualWithdrawl = annualWithdrawl || 0;
    this.interestRate =  DEFAULT_INTEREST_RATE;
  }

  DrawdownCalculatorModel.prototype.howLongMoneyWillLast = function () {
    var pensionPot =  this.presentValue,
        annualWithdrawl = this.annualWithdrawl,
        interestRate = this.interestRate,
        years = 0;

    while (pensionPot > annualWithdrawl) {
      pensionPot = (pensionPot - annualWithdrawl) * (1 + interestRate/100);
      years++;
    }

    return years + Math.round((pensionPot/annualWithdrawl) * 10)/10;
  };

  global.DrawdownCalculatorModel = DrawdownCalculatorModel;

})(this);
