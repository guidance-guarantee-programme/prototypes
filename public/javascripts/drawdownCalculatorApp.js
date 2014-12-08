$(function() {

  var MONTHS_IN_A_YEAR = 12

  $('#js-calculate').click(function(){

    if (!$('#pension').val()) {
      $('#pension').val('0');
    }

    if (!$('#payment').val()) {
      $('#payment').val('0');
    }

    var presentValue = parseInt($('#pension').val(), 10);
    var payment = parseInt($('#payment').val(), 10);
    var withdrawlFrequency = $("input[name=withdrawl-frequency]:checked").val();
    var annualWithdrawl = (withdrawlFrequency == 'Yearly')? payment: payment * MONTHS_IN_A_YEAR;

    var calc = new DrawdownCalculatorModel(presentValue, annualWithdrawl);

    $("#js-duration").text(decimalYearToString(calc.howLongMoneyWillLast()));

    $('.calculator__results').removeClass('is-hidden');

    $('html, body').animate({
      scrollTop: ($('.calculator__results').offset().top)
    },500);

  });
});
