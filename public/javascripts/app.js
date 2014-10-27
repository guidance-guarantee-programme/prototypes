$(function() {

  $('#js-calculate').click(function(){

    if ($('#income:text').is(":empty")) {
      $('#income').val('0')
    }

    var calc = new Calculator($('#pension').val(), $('#income').val());

    $("#js-lump-sum").text('#js-lump-sum-2').text(numeral(calc.tax_free_lump_sum).format('$0,0'));
    $("#js-pension-lost").text(numeral(calc.pension_lost_to_tax()).format('$0,0'));
    $("#js-pension-income").text(numeral(calc.pension_remaining_after_tax()).format('$0,0'));

    $('.pension-tax-calculator__results').removeClass('is-hidden');

    $('html, body').animate({
      scrollTop: ($('.pension-tax-calculator__results').offset().top)
    },500);

  });
});
