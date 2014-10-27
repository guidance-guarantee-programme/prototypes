function Calculator(pension, income) {
  this.pension = parseInt(pension.replace(/,/g, ''));
  this.income = parseInt(income.replace(/,/g, ''));

  this.tax_free_lump_sum = this.pension * 25 / 100;
  this.taxable_pension = this.pension * 75 / 100;

  this.taxable_income = this.income + this.taxable_pension;

  this.PERSONAL_ALLOWANCE = 10000;
  this.BASIC_RATE_MAX = 41866;
  this.BASIC_RATE_TAX = 20;
  this.HIGHER_RATE_MAX = 160000;
  this.HIGHER_RATE_TAX = 40;
  this.ADDITIONAL_RATE_TAX = 45;
}

Calculator.prototype.pension_lost_to_tax = function () {
  var taxable_pension_at_basic_rate,
      taxable_pension_at_higher_rate,
      taxable_pension_at_additional_rate;

  if (this.taxable_income < this.PERSONAL_ALLOWANCE) {
    return 0
  } else if (this.taxable_income < this.BASIC_RATE_MAX) {
    if (this.income > this.PERSONAL_ALLOWANCE) {
      return this.taxable_pension * this.BASIC_RATE_TAX / 100;
    } else {
      taxable_pension_at_basic_rate = this.taxable_income - this.PERSONAL_ALLOWANCE;
      return taxable_pension_at_basic_rate * this.BASIC_RATE_TAX / 100;
    }
  } else if (this.taxable_income < this.HIGHER_RATE_MAX) {
    if (this.income > this.BASIC_RATE_MAX) {
      return this.taxable_pension * this.HIGHER_RATE_TAX / 100;
    } else if (this.income > this.PERSONAL_ALLOWANCE) {
      taxable_pension_at_higher_rate = this.taxable_income - this.BASIC_RATE_MAX;
      taxable_pension_at_basic_rate = this.taxable_pension - taxable_pension_at_higher_rate;

      return (taxable_pension_at_higher_rate * this.HIGHER_RATE_TAX / 100) +
          (taxable_pension_at_basic_rate * this.BASIC_RATE_TAX / 100);
    } else {
      taxable_pension_at_higher_rate = this.taxable_income - this.BASIC_RATE_MAX;
      taxable_pension_at_basic_rate = this.BASIC_RATE_MAX - this.PERSONAL_ALLOWANCE;

      return (taxable_pension_at_higher_rate * this.HIGHER_RATE_TAX / 100) +
          (taxable_pension_at_basic_rate * this.BASIC_RATE_TAX / 100);
    }
  } else if (this.taxable_income > this.HIGHER_RATE_MAX) {
    if (this.income > this.HIGHER_RATE_MAX) {
      return this.taxable_pension * this.ADDITIONAL_RATE_TAX   / 100;
    } else if (this.income > this.BASIC_RATE_MAX) {
      taxable_pension_at_additional_rate = this.taxable_income - this.HIGHER_RATE_MAX;
      taxable_pension_at_higher_rate = this.taxable_pension - taxable_pension_at_additional_rate;

      return (taxable_pension_at_additional_rate * this.ADDITIONAL_RATE_TAX / 100) +
          (taxable_pension_at_higher_rate * this.HIGHER_RATE_TAX / 100);
    } else if (this.income > this.PERSONAL_ALLOWANCE) {
      taxable_pension_at_additional_rate = this.taxable_income - this.HIGHER_RATE_MAX;
      taxable_pension_at_higher_rate = this.HIGHER_RATE_MAX - this.BASIC_RATE_MAX;
      taxable_pension_at_basic_rate = this.BASIC_RATE_MAX - this.income;

      var pension_lost_to_tax =  (taxable_pension_at_additional_rate * this.ADDITIONAL_RATE_TAX / 100) +
          (taxable_pension_at_higher_rate * this.HIGHER_RATE_TAX / 100) +
          (taxable_pension_at_basic_rate * this.BASIC_RATE_TAX / 100);

      return parseFloat(pension_lost_to_tax.toFixed(2));
    } else if (this.income < this.PERSONAL_ALLOWANCE) {
      taxable_pension_at_additional_rate = this.taxable_income - this.HIGHER_RATE_MAX;
      taxable_pension_at_higher_rate = this.HIGHER_RATE_MAX - this.BASIC_RATE_MAX;
      taxable_pension_at_basic_rate = this.BASIC_RATE_MAX - this.PERSONAL_ALLOWANCE;

      var pension_lost_to_tax =  (taxable_pension_at_additional_rate * this.ADDITIONAL_RATE_TAX / 100) +
          (taxable_pension_at_higher_rate * this.HIGHER_RATE_TAX / 100) +
          (taxable_pension_at_basic_rate * this.BASIC_RATE_TAX / 100);

      return parseFloat(pension_lost_to_tax.toFixed(2));
    }
  }
};

Calculator.prototype.pension_remaining_after_tax = function () {
  return this.pension - this.pension_lost_to_tax();
};
