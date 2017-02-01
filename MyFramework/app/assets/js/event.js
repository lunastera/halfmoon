$('.input-text').each(function(){
  $(this).focus(function(){$(this).addClass('focus');});
  $(this).blur(function(){$(this).removeClass('focus');});
});

$('.submit').click(function(){
  $('ul').append('<li>' +
    $('input[name="type"]:radio:checked').val() +
    ': ' +
    $('#input-text').val() +
    '</li>');
});
