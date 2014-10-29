/* KB shortcuts for sending the form */
//alert(event.which);

// UP => Submit success
$(document).keydown( function(event) {
  if (event.which == 38) {
    $("#eval-success").submit();
  }
});

// DOWN => Submit success
$(document).keydown( function(event) {
  if (event.which == 40) {
    $("#eval-fail").submit();
  }
});

// K => Submit success
//$(document).keypress( function(event) {
//  if (event.which == 107) {
//    $("#eval-success").submit();
//  }
//});
//
//// F => Submit fail
//$(document).keypress( function(event) {
//  if (event.which == 102) {
//    $("#eval-fail").submit();
//  }
//});

/* Tip display */

var set_or_toggle_visibility = function( selector, visibility) {
  visibility = visibility || (($( selector).css('visibility') == 'hidden') ? 'visible' : 'hidden')
  $( selector).css('visibility', visibility);
}

// RIGHT => Flash show
$(document).keydown( function(event) {
  if (event.which == 39) {
    set_or_toggle_visibility('#tip', 'visible');
  }
});
$(document).keyup( function(event) {
  if (event.which == 39) {
    set_or_toggle_visibility('#tip', 'hidden');
  }
});

// SPACE => Toggle
$(document).keypress( function(event) {
  if (event.which == 32) {
    set_or_toggle_visibility('#tip');
  }
});

// Hover => Visible
$(document).ready( function() { 
  $('#tip-container').hover( 
    function(){ set_or_toggle_visibility('#tip', 'visible') },
    function(){ set_or_toggle_visibility('#tip', 'hidden') }
  );
});
