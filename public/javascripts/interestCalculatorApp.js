$(function() {

  var MONTHS_IN_A_YEAR = 12

  $('#js-calculate').click(function(){

    if (!$('#pension').val()) {
      $('#pension').val('0');
    }

    if (!$('#years').val()) {
      $('#years').val('0');
    }

    if (!$('#payment').val()) {
      $('#payment').val('0');
    }

    var presentValue = parseInt($('#pension').val(), 10);
    var yearsOfGrowth = parseInt($('#years').val(), 10);
    var annualPayment = parseInt($('#payment').val(), 10) * MONTHS_IN_A_YEAR;
    var calc = new InterestCalculatorModel(presentValue, yearsOfGrowth, annualPayment);

    $("#js-interest").text(numeral(calc.interest()).format('$0,0'));
    $("#js-total").text(numeral(calc.growthValue()).format('$0,0'));

    $('.calculator__results').removeClass('is-hidden');

    $('html, body').animate({
      scrollTop: ($('.calculator__results').offset().top)
    },500);

  });
});
